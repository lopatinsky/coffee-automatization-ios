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
    [self.cardAdditionViewHolder addSubview:_additionModule];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.cards count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBCardCell"];
    
    if (!cell) {
        cell = [DBCardCell new];
    }
    
    NSDictionary *card = self.cards[indexPath.row];
    NSString *cardNumber = card[@"cardPan"];
    NSString *pan = [NSString stringWithFormat:@"....%@", [cardNumber substringFromIndex:cardNumber.length-4]];
    cell.cardTitleLabel.text = [NSString stringWithFormat:@"%@ - %@", [cardNumber db_cardIssuer], pan];
    
    [cell.cardIconImageView templateImageWithName:@"card"];
    cell.cardTitleLabel.textColor = [UIColor blackColor];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView beginUpdates];
    
    NSUInteger k = indexPath.row;
    NSDictionary *card = self.cards[k];
    
    [[IHSecureStore sharedInstance] removeCardAtIndex:k];
    
    self.cards = [[IHSecureStore sharedInstance] cards];
    
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    
    [[IHPaymentManager sharedInstance] unbindCard:card[@"cardToken"]];
    
    [GANHelper analyzeEvent:@"remove_card_success" category:self.screen];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *eventLabel;
    // Extra payment type
    if(indexPath.section == 0){
        eventLabel = @"extra";
        _orderManager.paymentType = PaymentTypeExtraType;
        [self.tableView reloadData];
        
        [self.delegate cardsControllerDidChoosePaymentItem:self];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    // Cash payment type
    if(indexPath.section == 1){
        eventLabel = @"cash";
        _orderManager.paymentType = PaymentTypeCash;
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
                _orderManager.paymentType = PaymentTypeCard;
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
    
    // PayPal payment type
    if(indexPath.section == 3){
        eventLabel = @"paypal";
        
        if(_payPalManager.loggedIn){
            if(self.mode == CardsViewControllerModeChoosePayment){
                _orderManager.paymentType = PaymentTypePayPal;
                [self.tableView reloadData];
                
                [self.delegate cardsControllerDidChoosePaymentItem:self];
                [self.navigationController popViewControllerAnimated:YES];
            }
        } else {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [_payPalManager bindPayPal:^(DBPayPalBindingState state, NSString *message) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                
                if(state == DBPayPalBindingStateDone){
                    [self.tableView reloadData];
                }
                
                if(state == DBPayPalBindingStateFailure){
                    if(!message)
                        message = @"Произошла непредвиденная ошибка! Пожалуйста, попробуйте еще раз!";
                    
                    [self showError:message];
                }
            }];
        }
    }
    
    [GANHelper analyzeEvent:@"payment_selected" label:eventLabel category:PAYMENT_SCREEN];
}

@end
