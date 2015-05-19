//
//  DBCardsViewController.m
//  DoubleB
//
//  Created by Sergey Pronin on 8/1/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "UIViewController+DBCardManagement.h"
#import "DBCardsViewController.h"
#import "IHSecureStore.h"
#import "OrderManager.h"
#import "IHPaymentManager.h"
#import "DBMastercardAdView.h"
#import "DBProfileViewController.h"
#import "DBAPIClient.h"
#import "DBCardCell.h"
#import "DBMastercardPromo.h"
#import "DBPromoManager.h"
#import "DBClientInfo.h"
#import "Compatibility.h"

@interface DBCardsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *advertView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintAdvertViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintAdvertViewTopSpace;

@property (nonatomic, strong) NSArray *cards;
@property (strong, nonatomic) NSArray *availablePaymentTypes;
@property (strong, nonatomic) DBMastercardPromo *mastercardPromo;
 
@end

@implementation DBCardsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if([self.screen isEqualToString:@"Cards_screen"]){
        self.title = NSLocalizedString(@"Карты", nil);
    } else {
        self.title = NSLocalizedString(@"Оплата", nil);
    }
    
    self.tableView.backgroundColor = [UIColor db_backgroundColor];
    self.tableView.rowHeight = 50;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.tableFooterView = [UIView new];
    
    self.availablePaymentTypes = [[NSUserDefaults standardUserDefaults] objectForKey:kDBDefaultsAvailablePaymentTypes];
    
    double topY = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.constraintAdvertViewTopSpace.constant = topY;

    self.mastercardPromo = [DBMastercardPromo sharedInstance];
    
    [self reloadCards];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [GANHelper analyzeScreen:self.screen];
    
    // Configure Mastercard promo
    if([self.mastercardPromo promoIsAvailable] && ![self.mastercardPromo userIntoPromo]){
        DBMastercardAdView *mcAdView = [[DBMastercardAdView alloc] initWithDelegate:nil onScreen:self.screen];
        mcAdView.backgroundColor = [UIColor db_backgroundColor];
        mcAdView.plusImageView.hidden = YES;
        self.constraintAdvertViewHeight.constant = mcAdView.frame.size.height;
        self.advertView.hidden = NO;
        [self.advertView addSubview:mcAdView];
    } else {
        self.constraintAdvertViewHeight.constant = 0;
        self.advertView.hidden = YES;
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (!parent) {
        if([self.screen isEqualToString:@"Cards_payment_screen"]){
        }
        [GANHelper analyzeEvent:@"back_arrow_pressed" category:PAYMENT_SCREEN];
    }
}

- (void)reloadCards {
    self.cards = [[IHSecureStore sharedInstance] cards];
    [self.tableView reloadData];
}

- (void)clickEdit:(id)sender {
    if (self.tableView.editing) {
        [self.tableView setEditing:NO animated:YES];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(clickEdit:)];
    } else {
        [self.tableView setEditing:YES animated:NO];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(clickEdit:)];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int result = 0;
    
    if(self.mode == CardsViewControllerModeManageCards){
        if(section == 2) {
            return [self.cards count] + 1;
        } else {
            return 0;
        }
    }
    
    // Extra payment type
    if(section == 0){
        result += self.mastercardPromo.promoCurrentMugCount > 0 ? 1 : 0;
    }
    
    // Cash payment type
    if(section == 1){
        result += [self.availablePaymentTypes containsObject:@(PaymentTypeCash)] ? 1 : 0;
    }
    
    // Cards payment type
    if(section == 2){
        result += [self.cards count] + 1;
    }
    
    return result;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBCardCell"];
    
    if (!cell) {
        cell = (DBCardCell *)[[[NSBundle mainBundle] loadNibNamed:@"DBCardCell" owner:self options:nil] firstObject];
    }
    
    // Extra payment type
    if(indexPath.section == 0){
        cell.cardTitleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d кофе в подарок", nil), (int)[DBMastercardPromo sharedInstance].promoCurrentMugCount];
        if([DBMastercardPromo sharedInstance].promoCurrentMugCount >= [OrderManager sharedManager].totalCount){
            [cell.cardIconImageView templateImageWithName:@"mug"];
            cell.cardTitleLabel.textColor = [UIColor blackColor];
            if ([OrderManager sharedManager].paymentType == PaymentTypeExtraType) {
                [cell.cardActiveIndicator templateImageWithName:@"tick"];
            } else {
                cell.cardActiveIndicator.hidden = YES;
            }
        } else {
            [cell.cardIconImageView templateImageWithName:@"mug_gray"];
            cell.cardActiveIndicator.hidden = YES;
            cell.cardTitleLabel.textColor = [UIColor grayColor];
            cell.userInteractionEnabled = NO;
        }
    }
    
    // Cash payment type
    if(indexPath.section == 1){
        cell.cardTitleLabel.text = NSLocalizedString(@"Наличные", nil);
        [cell.cardIconImageView templateImageWithName:@"cash"];
        cell.cardTitleLabel.textColor = [UIColor blackColor];
        if ([OrderManager sharedManager].paymentType == PaymentTypeCash) {
            [cell.cardActiveIndicator templateImageWithName:@"tick"];
        } else {
            cell.cardActiveIndicator.hidden = YES;
        }
    }
    
    // Cards payment type
    if(indexPath.section == 2){
        // add card button
        if(indexPath.row == [self.cards count]){
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBCardAddCell"];
            if (!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"DBCardAddCell" owner:self options:nil] firstObject];
            }
            UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:1];
            titleLabel.textColor = [UIColor db_defaultColor];
            titleLabel.text = NSLocalizedString(@"Добавить карту", nil);
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
        } else {
            NSDictionary *card = self.cards[indexPath.row];
            NSString *cardNumber = card[@"cardPan"];
            NSString *pan = [NSString stringWithFormat:@"....%@", [cardNumber substringFromIndex:cardNumber.length-4]];
            cell.cardTitleLabel.text = [NSString stringWithFormat:@"%@ - %@", [cardNumber db_cardIssuer], pan];
            
            [cell.cardIconImageView templateImageWithName:@"card"];
            cell.cardTitleLabel.textColor = [UIColor blackColor];
            if ([card[@"default"] boolValue] &&
                ([OrderManager sharedManager].paymentType == PaymentTypeCard || self.mode == CardsViewControllerModeManageCards)) {
                [cell.cardActiveIndicator templateImageWithName:@"tick"];
            } else {
                cell.cardActiveIndicator.hidden = YES;
            }
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.mode == CardsViewControllerModeManageCards && indexPath.section == 2 && indexPath.row < [self.cards count];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section == 2) ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView beginUpdates];

    NSUInteger k = indexPath.row - (NSUInteger)self.mode;
    NSDictionary *card = self.cards[k];
    
    [[IHSecureStore sharedInstance] removeCardAtIndex:k];
    
    self.cards = [[IHSecureStore sharedInstance] cards];
    
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    
    [[IHPaymentManager sharedInstance] unbindCard:card[@"cardToken"]];
    
    [tableView endUpdates];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *eventLabel;
    // Extra payment type
    if(indexPath.section == 0){
        eventLabel = @"extra";
        [OrderManager sharedManager].paymentType = PaymentTypeExtraType;
        [self.tableView reloadData];
        
        [self.delegate cardsControllerDidChoosePaymentItem:self];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    // Cash payment type
    if(indexPath.section == 1){
        eventLabel = @"cash";
        [OrderManager sharedManager].paymentType = PaymentTypeCash;
        [self.tableView reloadData];
        
        [self.delegate cardsControllerDidChoosePaymentItem:self];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    // Cards payment type
    if(indexPath.section == 2){
        eventLabel = @"card";
        // add card button
        if(indexPath.row == [self.cards count]){
            [GANHelper analyzeEvent:@"add_card_pressed" category:PAYMENT_SCREEN];
            [self db_cardManagementBindNewCardOnScreen:self.screen callback:^(BOOL success) {
                if(success){
                    [self reloadCards];
                }
            }];
        } else {
            if (self.mode == CardsViewControllerModeChoosePayment) {
                [OrderManager sharedManager].paymentType = PaymentTypeCard;
            }
            
            if (self.mode == CardsViewControllerModeManageCards){
                [GANHelper analyzeEvent:@"check_card"
                                  label:[NSString stringWithFormat:@"%d", (int)[self.cards count]]
                               category:self.screen];
            }
            
            NSDictionary *card = self.cards[indexPath.row];
            [[IHSecureStore sharedInstance] setDefaultCardWithBindingId:card[@"cardToken"]];
            [self reloadCards];
            
            eventLabel = [[card[@"cardPan"] db_cardIssuer] stringByAppendingString:@"_card"];
            
            [self.delegate cardsControllerDidChoosePaymentItem:self];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
    [GANHelper analyzeEvent:@"payment_selected" label:eventLabel category:PAYMENT_SCREEN];
}


#pragma mark - other methods

- (NSString *)getCurrentSelectedPaymentType{
    NSString *result = @"0";
    
    switch ([OrderManager sharedManager].paymentType) {
        case PaymentTypeNotSet:
            result = @"0";
            break;
        case PaymentTypeCash:
            result = @"1";
            break;
        case PaymentTypeCard:
            result = @"2";
            break;
        case PaymentTypeExtraType:
            result = @"3";
            break;
    }
    
    return result;
}

@end
