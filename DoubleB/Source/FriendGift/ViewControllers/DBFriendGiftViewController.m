//
//  DBFriendGiftViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 04.03.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBFriendGiftViewController.h"
#import "DBModuleView.h"
#import "DBModuleHeaderView.h"
#import "DBFGItemsModuleView.h"
#import "DBFGRecipientModuleView.h"
#import "DBFGPaymentModule.h"
#import "DBBarButtonItem.h"
#import "DBFriendGiftHistoryTableViewController.h"

#import "DBFriendGiftHelper.h"
#import "Compatibility.h"
#import "MBProgressHUD.h"

#import "UIViewController+DBMessage.h"

#import "CAGradientLayer+Helper.h"
#import <BlocksKit/UIAlertView+BlocksKit.h>

@import AddressBookUI;

@interface DBFriendGiftViewController () <DBOwnerViewControllerProtocol>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet DBModuleView *giftInfoModule;

@property (weak, nonatomic) IBOutlet UIView *giftView;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UILabel *giftLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottomScrollViewAlignment;

@property (strong, nonatomic) NSString *analyticsScreen;
@property (strong, nonatomic) UITapGestureRecognizer *dismissKeyboardTap;
@property (nonatomic) BOOL keyboardIsVisible;

@end

@implementation DBFriendGiftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor db_backgroundColor];
    self.analyticsScreen = @"Friend_gift_screen";
    
    self.titleLabel.text = [DBFriendGiftHelper sharedInstance].titleFriendGiftScreen;
    self.descriptionLabel.text = [DBFriendGiftHelper sharedInstance].textFriendGiftScreen;
    
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.titleLabel alignTrailingEdgeWithView:self.view predicate:@"-15"];
    
    self.dismissKeyboardTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                      action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:self.dismissKeyboardTap];

    [self initModules];
    [self initGiftView];
    
    [[DBFriendGiftHelper sharedInstance] addObserver:self withKeyPaths:@[DBFriendGiftHelperNotificationFriendName, DBFriendGiftHelperNotificationFriendPhone, DBFriendGiftHelperNotificationItemsPrice] selector:@selector(reloadGiftButton)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
//    self.navigationItem.rightBarButtonItem = [DBBarButtonItem customItem:self withText:NSLocalizedString(@"История", nil) action:@selector(moveToHistory)];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = NSLocalizedString(@"Подарок", nil);
    
    if([DBFriendGiftHelper sharedInstance].items.count == 0) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[DBFriendGiftHelper sharedInstance] fetchItems:^(BOOL success) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self reload];
        }];
    }
 
    [self reload];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
    self.navigationItem.title = @"";
}

- (void)dealloc {
    [[DBFriendGiftHelper sharedInstance] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dismissKeyboard {
    [[NSNotificationCenter defaultCenter] postNotificationName:kDBFGRecipientModuleViewDismiss object:nil];
}

- (void)initModules {
    DBModuleHeaderView *recipientHeader = [DBModuleHeaderView new];
    recipientHeader.title = NSLocalizedString(@"Контактные данные вашего друга", nil);
    [self.giftInfoModule.submodules addObject:recipientHeader];
    
    DBFGRecipientModuleView *recipientModule = [DBFGRecipientModuleView new];
    recipientModule.analyticsCategory = self.analyticsScreen;
    recipientModule.ownerViewController = self;
    [self.giftInfoModule.submodules addObject:recipientModule];
    
    
    DBModuleHeaderView *itemsHeader = [DBModuleHeaderView new];
    itemsHeader.title = [DBFriendGiftHelper sharedInstance].type == DBFriendGiftTypeCommon ? NSLocalizedString(@"Выберите подарок", nil) : NSLocalizedString(@"Подарок", nil);
    [self.giftInfoModule.submodules addObject:itemsHeader];
    
    DBFGItemsModuleView *itemsModule = [DBFGItemsModuleView new];
    itemsModule.analyticsCategory = self.analyticsScreen;
    itemsModule.ownerViewController = self;
    [self.giftInfoModule.submodules addObject:itemsModule];
    
    
    if ([DBFriendGiftHelper sharedInstance].type == DBFriendGiftTypeCommon) {
        DBModuleHeaderView *paymentHeader = [DBModuleHeaderView new];
        paymentHeader.title = NSLocalizedString(@"Выберите карту для оплаты", nil);
        [self.giftInfoModule.submodules addObject:paymentHeader];
        
        DBFGPaymentModule *paymentModule = [DBFGPaymentModule new];
        paymentModule.analyticsCategory = self.analyticsScreen;
        paymentModule.ownerViewController = self;
        [self.giftInfoModule.submodules addObject:paymentModule];
    }
    
    [self.giftInfoModule layoutModules];
}

- (void)moveToHistory {
    UIViewController *vc = [DBFriendGiftHistoryTableViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)initGiftView {
    self.giftView.backgroundColor = [UIColor db_defaultColor];
    self.giftView.layer.cornerRadius = self.giftView.frame.size.height / 2;
    self.giftView.layer.masksToBounds = YES;
    
    self.giftLabel.text = NSLocalizedString(@"Подарить", nil);
    
    @weakify(self)
    [self.giftView addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self)
        [self clickGiftButton];
    }]];
}

- (void)clickGiftButton{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[DBFriendGiftHelper sharedInstance] processGift:^(NSString *smsText) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        [self presentMessageViewControllerWithText:smsText
                                        recipients:@[[DBFriendGiftHelper sharedInstance].friendPhone.value]
                                          callback:^(MessageComposeResult result) {
                                              if(result == MessageComposeResultSent){
                                                  [self.navigationController popViewControllerAnimated:YES];
                                                  [self showAlert:NSLocalizedString(@"Ваш подарок успешно отправлен", nil)];
                                              }
                                          }];
        
        [GANHelper analyzeEvent:@"gift_payment_success" category:self.analyticsScreen];
    } failure:^(NSString *errorDescription) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        [self showError:errorDescription];
        
        [GANHelper analyzeEvent:@"gift_payment_failure" category:self.analyticsScreen];
    }];
    
    NSString *label = [NSString stringWithFormat:@"%@,%@", [DBFriendGiftHelper sharedInstance].friendName.value, [DBFriendGiftHelper sharedInstance].friendPhone.value];
    [GANHelper analyzeEvent:@"gift_submit_click"
                      label:label
                   category:self.analyticsScreen];
}

- (void)reload {
    [self.giftInfoModule reload:NO];

    [self reloadGiftButton];
}

- (void)reloadGiftButton{
    self.totalLabel.text = [NSString stringWithFormat:@"%.0f %@", [DBFriendGiftHelper sharedInstance].itemsManager.totalPrice, [Compatibility currencySymbol]];
    
    self.giftView.userInteractionEnabled = [DBFriendGiftHelper sharedInstance].validData;
    self.giftView.alpha = [DBFriendGiftHelper sharedInstance].validData ? 1.0 : 0.5;
}

#pragma mark - DBOwnerViewControllerProtocol

- (void)reloadAllModules {
    [self.giftInfoModule reload:YES];
}

#pragma mark - Keyboard events

- (void)keyboardWillShow:(NSNotification *)notification{
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.constraintBottomScrollViewAlignment.constant = keyboardRect.size.height;
                         [self.view layoutIfNeeded];
                     }
                     completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification{
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.constraintBottomScrollViewAlignment.constant = 0;
                         [self.view layoutIfNeeded];
                     }
                     completion:nil];
    [self reloadGiftButton];
}

#pragma mark - DBSettingsProtocol

+ (id<DBSettingsItemProtocol>)settingsItem {
    DBFriendGiftViewController *vc = [DBFriendGiftViewController new];
    DBSettingsItem *settingsItem = [DBSettingsItem new];
    
    settingsItem.name = @"friendGiftVC";
    settingsItem.title = NSLocalizedString(@"Подарок другу", nil);
    settingsItem.iconName = @"gift_icon";
    settingsItem.viewController = vc;
    settingsItem.eventLabel = @"friend_gift_click";
    settingsItem.navigationType = DBSettingsItemNavigationPush;
    
    return settingsItem;
}
@end
