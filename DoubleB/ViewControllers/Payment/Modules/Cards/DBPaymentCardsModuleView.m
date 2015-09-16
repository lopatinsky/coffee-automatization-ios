//
//  DBPaymentCardsModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 18.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBPaymentCardsModuleView.h"
#import "DBPaymentCardAdditionModuleView.h"
#import "DBCardCell.h"

#import "DBCardsManager.h"
#import "IHPaymentManager.h"
#import "OrderCoordinator.h"

@interface DBPaymentCardsModuleView ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *cardsTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintCardsTableViewHeight;

@property (weak, nonatomic) IBOutlet UIView *cardAdditionViewHolder;

@property (strong, nonatomic) DBPaymentCardAdditionModuleView *additionModule;

@end

@implementation DBPaymentCardsModuleView

- (instancetype)initWithMode:(DBPaymentCardsModuleViewMode)mode{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBPaymentCardsModuleView" owner:self options:nil] firstObject];
    
    _mode = mode;
    
    [self commonInit];
    
    return self;
}

- (void)commonInit {
    self.cardsTableView.dataSource = self;
    self.cardsTableView.delegate = self;
    self.cardsTableView.rowHeight = 50;
    self.cardsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.cardsTableView.tableFooterView = [UIView new];
    
    _additionModule = [DBPaymentCardAdditionModuleView new];
    _additionModule.analyticsCategory = self.analyticsCategory;
    _additionModule.ownerViewController = self.ownerViewController;
    [self.cardAdditionViewHolder addSubview:_additionModule];
    _additionModule.translatesAutoresizingMaskIntoConstraints = NO;
    [_additionModule alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self.cardAdditionViewHolder];
    
    [self.submodules addObject:_additionModule];
    
    [[DBCardsManager sharedInstance] addObserver:self withKeyPath:DBCardsManagerNotificationCardsChanged selector:@selector(reload)];
    [[OrderCoordinator sharedInstance] addObserver:self withKeyPath:CoordinatorNotificationNewPaymentType selector:@selector(reload)];
    
    [self reload:NO];
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)dealloc {
    [[DBCardsManager sharedInstance] removeObserver:self];
    [[OrderCoordinator sharedInstance] removeObserver:self];
}

- (void)reload:(BOOL)animated {
    [super reload:animated];
    [self.cardsTableView reloadData];
    [self reloadTableViewHeight:animated];
}

- (NSInteger)cardsTableViewHeight {
    return [DBCardsManager sharedInstance].cardsCount * 50;
}

- (void)reloadTableViewHeight:(BOOL)animated{
    @weakify(self)
    void (^block)() = ^void(){
        @strongify(self)
        self.constraintCardsTableViewHeight.constant = [self cardsTableViewHeight];
        [self.cardsTableView layoutIfNeeded];
        [self layoutIfNeeded];
    };
    
    if(animated){
        [UIView animateWithDuration:0.3 animations:^{
            block();
        }];
    } else {
        block();
    }
    
    [self reloadHeight:animated];
}

- (void)reloadHeight:(BOOL)animated{
    @weakify(self)
    void (^block)() = ^void(){
        @strongify(self)
        [self invalidateIntrinsicContentSize];
        [self.cardsTableView layoutIfNeeded];
        [self layoutIfNeeded];
    };
    
    if(animated){
        [UIView animateWithDuration:0.3 animations:^{
            block();
        }];
    } else {
        block();
    }
}

- (CGSize)moduleViewContentSize {
    return CGSizeMake(self.frame.size.width,[self cardsTableViewHeight] + self.cardAdditionViewHolder.frame.size.height);
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [DBCardsManager sharedInstance].cardsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBCardCell"];
    
    if (!cell) {
        cell = [DBCardCell new];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    DBPaymentCard *card = [[DBCardsManager sharedInstance] cardAtIndex:indexPath.row];
    NSString *pan = [NSString stringWithFormat:@"....%@", [card.pan substringFromIndex:card.pan.length-4]];
    cell.cardTitleLabel.text = [NSString stringWithFormat:@"%@ - %@", card.cardIssuer, pan];
    
    [cell.cardIconImageView templateImageWithName:@"card"];
    cell.cardTitleLabel.textColor = [UIColor blackColor];
    
    if(_mode == DBPaymentCardsModuleViewModeManageCards) {
        cell.checked = [DBCardsManager sharedInstance].defaultCard == card;
    } else {
        cell.checked = [DBCardsManager sharedInstance].defaultCard == card && [OrderCoordinator sharedInstance].orderManager.paymentType == PaymentTypeCard;
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return _mode == DBPaymentCardsModuleViewModeManageCards;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView beginUpdates];
    
    DBPaymentCard *card = [[DBCardsManager sharedInstance] cardAtIndex:indexPath.row];
    
    [[IHPaymentManager sharedInstance] unbindCard:card.token];
    [[DBCardsManager sharedInstance] removeCard:card];
    
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self reloadTableViewHeight:YES];
    [tableView endUpdates];
    
    [GANHelper analyzeEvent:@"remove_card_success" category:self.analyticsCategory];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DBPaymentCard *card = [[DBCardsManager sharedInstance] cardAtIndex:indexPath.row];
    [DBCardsManager sharedInstance].defaultCard = card;
    
    if (_mode == DBPaymentCardsModuleViewModeSelectPayment) {
        [OrderCoordinator sharedInstance].orderManager.paymentType = PaymentTypeCard;
        
        NSString *eventLabel = [card.cardIssuer stringByAppendingString:@"_card"];
        [GANHelper analyzeEvent:@"payment_selected" label:eventLabel category:self.analyticsCategory];
    }
    
    if (_mode == DBPaymentCardsModuleViewModeManageCards){
        [GANHelper analyzeEvent:@"check_card"
                          label:[NSString stringWithFormat:@"%d", (int)[DBCardsManager sharedInstance].cardsCount]
                       category:self.analyticsCategory];
    }
    
    if([self.delegate respondsToSelector:@selector(db_paymentModuleDidSelectPaymentType:)]){
        [self.delegate db_paymentModuleDidSelectPaymentType:PaymentTypeCard];
    }
}

@end
