//
//  DBNOOrderModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 17/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBNOOrderModuleView.h"
#import "UIView+RoundedCorners.h"
#import "OrderCoordinator.h"
#import "NetworkManager.h"
#import "DBClientInfo.h"
#import "DBShareHelper.h"

#import "DBServerAPI.h"
#import "MBProgressHUD.h"
#import "UIAlertView+BlocksKit.h"

@interface DBNOOrderModuleView ()
@property (weak, nonatomic) IBOutlet UIButton *orderButton;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *topSeparator;

@property (nonatomic) BOOL activeTasks;

@end

@implementation DBNOOrderModuleView

+ (NSString *)xibName {
    return @"DBNOOrderModuleView";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
//    [self.orderButton setRoundedCorners];
    [self.orderButton setTitle:NSLocalizedString(@"Отправить заказ", nil) forState:UIControlStateNormal];
    [self.orderButton setTitleColor:[UIColor db_defaultColor] forState:UIControlStateNormal];
    [self.orderButton addTarget:self action:@selector(clickOrderButton) forControlEvents:UIControlEventTouchUpInside];
    
    self.topSeparator.backgroundColor = [UIColor db_defaultColor];
    
    NSArray *events = @[CoordinatorNotificationNewDeliveryType, CoordinatorNotificationNewSelectedTime, CoordinatorNotificationNewPaymentType, CoordinatorNotificationNewVenue, CoordinatorNotificationNewShippingAddress, CoordinatorNotificationNDAAccept];
    [[OrderCoordinator sharedInstance] addObserver:self withKeyPaths:events selector:@selector(reload)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endAnimating) name:kDBConcurrentOperationCheckOrderSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endAnimating) name:kDBConcurrentOperationCheckOrderFailure object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startAnimating) name:kDBConcurrentOperationCheckOrderStarted object:nil];
}

- (void)viewWillAppearOnVC {
    [self reload:NO];
}

- (void)dealloc {
    [[OrderCoordinator sharedInstance] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reload:(BOOL)animated {
    [super reload:animated];
    
    if (_activeTasks == 0) {
        if (![OrderCoordinator sharedInstance].validOrder) {
            self.errorLabel.hidden = NO;
            self.errorLabel.text = [OrderCoordinator sharedInstance].orderErrorReason;
            
            self.orderButton.hidden = YES;
            
            self.backgroundColor = [UIColor db_errorColor:0.85f];
            self.topSeparator.hidden = YES;
        } else {
            self.errorLabel.hidden = YES;
            self.orderButton.hidden = NO;
            [self reloadOrderButton];
            
            self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.85f];
            self.topSeparator.hidden = NO;
        }
    } else {
        self.errorLabel.hidden = YES;
        self.orderButton.hidden = YES;
        
        self.activityIndicator.color = [OrderCoordinator sharedInstance].validOrder ? [UIColor grayColor] : [UIColor whiteColor];
//        self.backgroundColor = [UIColor db_errorColor:0.85f];
    }
}

- (void)reloadOrderButton {
    if (![OrderCoordinator sharedInstance].validOrder) {
//        self.orderButton.backgroundColor = [UIColor db_grayColor];
        self.orderButton.alpha = 0.5f;
    } else {
//        self.orderButton.backgroundColor = [UIColor db_defaultColor];
        self.orderButton.alpha = 1;
    }
}

- (void)startAnimating {
    if (_activeTasks) { return; }
    _activeTasks = YES;;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator startAnimating];
        [self reload:YES];
    });
}

- (void)endAnimating {
    if (!_activeTasks) { return; }
    _activeTasks = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator stopAnimating];
        [self reload:YES];
    });
}

- (void)clickOrderButton {
    [GANHelper analyzeEvent:@"order_button_click" category:ORDER_SCREEN];
    
    [MBProgressHUD showHUDAddedTo:self.ownerViewController.view animated:YES];
    [DBServerAPI createNewOrder:^(Order *order) {
        [MBProgressHUD hideHUDForView:self.ownerViewController.view animated:YES];
        
        [[ApplicationManager sharedInstance] moveToScreen:ApplicationScreenHistoryOrder object:order animated:YES];
        
        NSString *message = NSLocalizedString(@"Заказ отправлен. Мы вас ждем!", nil);
        if (order.deliveryType.integerValue == DeliveryTypeIdShipping) {
            message = NSLocalizedString(@"Заказ отправлен. Мы с вами свяжемся для подтверждения!", nil);
        }
        [UIAlertView bk_showAlertViewWithTitle:order.venueName
                                       message:message
                             cancelButtonTitle:NSLocalizedString(@"OK", nil)
                             otherButtonTitles:nil
                                       handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                           // Show suggestion to share
                                           if ([DBShareHelper sharedInstance].shareSuggestionIsAvailable) {
                                               dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                   [[DBShareHelper sharedInstance] showShareSuggestion:YES];
                                               });
                                           }
                                       }];
    } failure:^(NSString *errorTitle, NSString *errorMessage) {
        [MBProgressHUD hideAllHUDsForView:self.ownerViewController.view animated:YES];

        if(!errorTitle) errorTitle = NSLocalizedString(@"Ошибка", nil);
        [UIAlertView bk_showAlertViewWithTitle:errorTitle
                                       message:errorMessage
                             cancelButtonTitle:NSLocalizedString(@"ОК", nil)
                             otherButtonTitles:nil
                                       handler:nil];
    }];
}

@end
