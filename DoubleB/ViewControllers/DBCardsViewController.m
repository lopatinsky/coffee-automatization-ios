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
#import "OrderCoordinator.h"
#import "IHPaymentManager.h"
#import "DBAPIClient.h"
#import "DBCardCell.h"
#import "DBPromoManager.h"
#import "DBClientInfo.h"
#import "Compatibility.h"
#import "MBProgressHUD.h"
#import "DBPayPalManager.h"

@interface DBCardsViewController () <UITableViewDataSource, UITableViewDelegate, DBPayPalManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *advertView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintAdvertViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintAdvertViewTopSpace;

@property (nonatomic, strong) NSArray *cards;
@property (strong, nonatomic) NSArray *availablePaymentTypes;

@property (strong, nonatomic) OrderManager *orderManager;
@property (strong, nonatomic) DBPayPalManager *payPalManager;
 
@end

@implementation DBCardsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if([self.screen isEqualToString:@"Cards_screen"]){
        self.title = NSLocalizedString(@"Карты", nil);
    } else {
        self.title = NSLocalizedString(@"Оплата", nil);
    }
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
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

    self.orderManager = [OrderCoordinator sharedInstance].orderManager;
    
    self.payPalManager = [DBPayPalManager sharedInstance];
    self.payPalManager.delegate = self;
    
    if([self.availablePaymentTypes containsObject:@(PaymentTypePayPal)]){
        self.title = NSLocalizedString(@"Электронные платежи", nil);
    }
    
    [self reloadCards];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [GANHelper analyzeScreen:self.screen];
    
    self.constraintAdvertViewHeight.constant = 0;
    self.advertView.hidden = YES;
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
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int result = 0;
    
    // Extra payment type
    if(section == 0){
        result += 0;
    }
    
    // Cash payment type
    if(section == 1){
        BOOL available = [self.availablePaymentTypes containsObject:@(PaymentTypeCash)] && self.mode == CardsViewControllerModeChoosePayment;
        result += available ? 1 : 0;
    }
    
    // Cards payment type
    if(section == 2){
        result += [self.availablePaymentTypes containsObject:@(PaymentTypeCard)] ? [self.cards count] + 1 : 0;
    }
    
    // PayPal payment type
    if(section == 3){
        result += [self.availablePaymentTypes containsObject:@(PaymentTypePayPal)] ? 1 : 0;
    }
    
    return result;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBCardCell"];
    
    if (!cell) {
        cell = [DBCardCell new];
    }
    
    // Cash payment type
    if(indexPath.section == 1){
        cell.cardTitleLabel.text = NSLocalizedString(@"Наличные", nil);
        [cell.cardIconImageView templateImageWithName:@"cash"];
        cell.cardTitleLabel.textColor = [UIColor blackColor];
        
        cell.checked = _orderManager.paymentType == PaymentTypeCash;
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
            
            cell.checked = [card[@"default"] boolValue] &&
            (_orderManager.paymentType == PaymentTypeCard || self.mode == CardsViewControllerModeManageCards);
        }
    }
    
    // PayPal payment type
    if(indexPath.section == 3){
        cell.cardIconImageView.image = [UIImage imageNamed:@"paypal_icon"];
        
        if(_payPalManager.loggedIn){
            cell.cardTitleLabel.textColor = [UIColor blackColor];
            cell.cardTitleLabel.text = @"использовать PayPal";
        } else {
            cell.cardTitleLabel.textColor = [UIColor db_defaultColor];
            cell.cardTitleLabel.text = @"Войти в аккаунт PayPal";
        }
        
        cell.checked = (_orderManager.paymentType == PaymentTypePayPal && self.mode == CardsViewControllerModeChoosePayment);
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL result = NO;
    
    result = result || (self.mode == CardsViewControllerModeManageCards && indexPath.section == 2 && indexPath.row < [self.cards count]);
    
    result = result || (self.mode == CardsViewControllerModeManageCards && indexPath.section == 3 && [DBPayPalManager sharedInstance].loggedIn);
    
    return result;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section == 2 || indexPath.section == 3) ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView beginUpdates];

    if(indexPath.section == 2){
        NSUInteger k = indexPath.row;
        NSDictionary *card = self.cards[k];
        
        [[IHSecureStore sharedInstance] removeCardAtIndex:k];
        
        self.cards = [[IHSecureStore sharedInstance] cards];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        [[IHPaymentManager sharedInstance] unbindCard:card[@"cardToken"]];
    }
    
    if(indexPath.section == 3){
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[DBPayPalManager sharedInstance] unbindPayPal:^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self.tableView reloadData];
        }];
    }
    
    [tableView endUpdates];
    
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


#pragma mark - DBPayPalManagerDelegate

- (void)payPalManager:(DBPayPalManager *)manager shouldPresentViewController:(UIViewController *)controller{
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)payPalManager:(DBPayPalManager *)manager shouldDismissViewController:(UIViewController *)controller{
    [controller dismissViewControllerAnimated:YES completion:nil];
}


@end
