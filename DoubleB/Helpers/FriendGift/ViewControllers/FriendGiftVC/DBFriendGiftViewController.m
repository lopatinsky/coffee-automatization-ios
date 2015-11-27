//
//  DBFriendGiftViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 04.03.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBFriendGiftViewController.h"
#import "DBModuleView.h"
#import "DBFGItemsModuleView.h"
#import "DBFGRecipientModuleView.h"
#import "DBFGPaymentModule.h"
#import "DBBarButtonItem.h"
#import "DBFriendGiftHistoryTableViewController.h"

#import "DBFriendGiftHelper.h"
#import "Compatibility.h"
#import "MBProgressHUD.h"
#import "DBSuggestionView.h"

#import "UIViewController+DBMessage.h"

#import "CAGradientLayer+Helper.h"
#import <BlocksKit/UIAlertView+BlocksKit.h>

@import AddressBookUI;

@interface DBFriendGiftViewController ()<DBSuggestionViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet DBModuleView *giftInfoModule;

@property (weak, nonatomic) IBOutlet UIView *giftView;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UILabel *giftLabel;

@property (strong, nonatomic) NSString *analyticsScreen;

@property (strong, nonatomic) DBSuggestionView *suggestionView;

@end

@implementation DBFriendGiftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Подарок", nil);
    
    self.view.backgroundColor = [UIColor db_backgroundColor];
    
    self.analyticsScreen = @"Friend_gift_screen";
    
    self.titleLabel.text = [DBFriendGiftHelper sharedInstance].titleFriendGiftScreen;
    self.descriptionLabel.text = [DBFriendGiftHelper sharedInstance].textFriendGiftScreen;
    
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.titleLabel alignTrailingEdgeWithView:self.view predicate:@"-15"];
    
    [self initModules];
    
    [self initGiftView];
    
    [self checkSuggestion:NO];
    
    [[DBFriendGiftHelper sharedInstance] addObserver:self withKeyPaths:@[DBFriendGiftHelperNotificationFriendName, DBFriendGiftHelperNotificationFriendPhone, DBFriendGiftHelperNotificationItemsPrice] selector:@selector(reloadGiftButton)];
    
    
    self.navigationItem.rightBarButtonItem = [DBBarButtonItem customItem:self withText:NSLocalizedString(@"История", nil) action:@selector(moveToHistory)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self reload];
}

- (void)dealloc{
    [[DBFriendGiftHelper sharedInstance] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initModules {
    DBFGRecipientModuleView *recipientModule = [DBFGRecipientModuleView new];
    recipientModule.analyticsCategory = self.analyticsScreen;
    recipientModule.ownerViewController = self;
    [self.giftInfoModule.submodules addObject:recipientModule];
    
    DBFGItemsModuleView *itemsModule = [DBFGItemsModuleView new];
    itemsModule.analyticsCategory = self.analyticsScreen;
    itemsModule.ownerViewController = self;
    [self.giftInfoModule.submodules addObject:itemsModule];
    
    DBFGPaymentModule *paymentModule = [DBFGPaymentModule new];
    paymentModule.analyticsCategory = self.analyticsScreen;
    paymentModule.ownerViewController = self;
    [self.giftInfoModule.submodules addObject:paymentModule];
    
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
        
        [self showMessageVC];
        
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

- (void)checkSuggestion:(BOOL)animated {
    if([DBFriendGiftHelper sharedInstance].smsText.length > 0){
        if(!self.suggestionView){
            self.suggestionView = [DBSuggestionView new];
            self.suggestionView.title = @"";
            self.suggestionView.delegate = self;
            
            [self.suggestionView showOnView:self.view animated:animated];
        }
    }
}

- (void)showMessageVC {
    [self presentMessageViewControllerWithText:[DBFriendGiftHelper sharedInstance].smsText
                                    recipients:@[[DBFriendGiftHelper sharedInstance].friendPhone.value]
                                      callback:^(MessageComposeResult result) {
                                          if(result == MessageComposeResultSent){
                                              [self.navigationController popViewControllerAnimated:YES];
                                              [self showAlert:NSLocalizedString(@"Ваш подарок успешно отправлен", nil)];
                                          }
                                          if(result == MessageComposeResultFailed || result == MessageComposeResultCancelled){
                                          }
                                          
                                          [self checkSuggestion:YES];
                                      }];
}

#pragma mark - DBSuggestionViewDelegate

- (void)db_clickSuggestionView:(DBSuggestionView *)view {
    [self showMessageVC];
}

- (void)db_closeSuggestionView:(DBSuggestionView *)view {
    [DBFriendGiftHelper sharedInstance].smsText = nil;
    [self.suggestionView hide:YES completion:^{
        self.suggestionView = nil;
    }];
}

#pragma mark - Keyboard events

- (void)keyboardWillShow:(NSNotification *)notification{
}

- (void)keyboardWillHide:(NSNotification *)notification{
}



@end
