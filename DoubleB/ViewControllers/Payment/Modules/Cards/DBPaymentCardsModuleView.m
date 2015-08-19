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
@property (weak, nonatomic) IBOutlet UIView *cardAdditionViewHolder;

@property (strong, nonatomic) DBPaymentCardAdditionModuleView *additionModule;

@end

@implementation DBPaymentCardsModuleView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBPaymentCardsModuleView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    self.cardsTableView.dataSource = self;
    self.cardsTableView.delegate = self;
    self.cardsTableView.rowHeight = 50;
    self.cardsTableView.tableFooterView = [UIView new];
    
    _additionModule = [DBPaymentCardAdditionModuleView new];
    _additionModule.analyticsCategory = self.analyticsCategory;
    [self.cardAdditionViewHolder addSubview:_additionModule];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [DBCardsManager sharedInstance].cardsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBCardCell"];
    
    if (!cell) {
        cell = [DBCardCell new];
    }
    
    DBPaymentCard *card = [[DBCardsManager sharedInstance] cardAtIndex:indexPath.row];
    NSString *pan = [NSString stringWithFormat:@"....%@", [card.pan substringFromIndex:card.pan.length-4]];
    cell.cardTitleLabel.text = [NSString stringWithFormat:@"%@ - %@", [card.pan db_cardIssuer], pan];
    
    [cell.cardIconImageView templateImageWithName:@"card"];
    cell.cardTitleLabel.textColor = [UIColor blackColor];
    
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
    [tableView endUpdates];
    
    [GANHelper analyzeEvent:@"remove_card_success" category:self.analyticsCategory];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [DBCardsManager sharedInstance].defaultCard = [[DBCardsManager sharedInstance] cardAtIndex:indexPath.row];
    
    if (_mode == DBPaymentCardsModuleViewModeSelectCard) {
        [OrderCoordinator sharedInstance].orderManager.paymentType = PaymentTypeCard;
        [GANHelper analyzeEvent:@"payment_selected" label:@"card" category:self.analyticsCategory];
    }
    
    if (_mode == DBPaymentCardsModuleViewModeManageCards){
        [GANHelper analyzeEvent:@"check_card"
                          label:[NSString stringWithFormat:@"%d", (int)[DBCardsManager sharedInstance].cardsCount]
                       category:self.analyticsCategory];
    }
}

@end
