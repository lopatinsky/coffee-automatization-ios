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

@property (weak, nonatomic) IBOutlet UIButton *giftButton;

@property (strong, nonatomic) NSString *analyticsScreen;

@property (strong, nonatomic) DBSuggestionView *suggestionView;

@end

@implementation DBFriendGiftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Подарок", nil);
    
    self.analyticsScreen = @"Friend_gift_screen";
    
    self.titleLabel.text = [DBFriendGiftHelper sharedInstance].titleFriendGiftScreen;
    self.descriptionLabel.text = [DBFriendGiftHelper sharedInstance].textFriendGiftScreen;
    
    [self initModules];
    
    [self initGiftButton];
    
    [self checkSuggestion:NO];
    
    [[DBFriendGiftHelper sharedInstance] addObserver:self withKeyPaths:@[DBFriendGiftHelperNotificationFriendName, DBFriendGiftHelperNotificationFriendPhone] selector:@selector(reloadGiftButton)];
    
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
    
    [self.giftInfoModule reload];
    [self reloadGiftButton];
}

- (void)dealloc{
    [[DBFriendGiftHelper sharedInstance] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initModules {
    DBFGItemsModuleView *itemsModule = [DBFGItemsModuleView new];
    itemsModule.analyticsCategory = self.analyticsScreen;
    itemsModule.ownerViewController = self;
    [self.giftInfoModule.submodules addObject:itemsModule];
    
    DBFGRecipientModuleView *recipientModule = [DBFGRecipientModuleView new];
    recipientModule.analyticsCategory = self.analyticsScreen;
    recipientModule.ownerViewController = self;
    [self.giftInfoModule.submodules addObject:recipientModule];
    
    DBFGPaymentModule *paymentModule = [DBFGPaymentModule new];
    paymentModule.analyticsCategory = self.analyticsScreen;
    paymentModule.ownerViewController = self;
    [self.giftInfoModule.submodules addObject:paymentModule];
    
    [self.giftInfoModule layoutModules];
}

- (void)initGiftButton {
    [self.giftButton setTitle:NSLocalizedString(@"Подарить", nil) forState:UIControlStateNormal];
    [self.giftButton addTarget:self action:@selector(clickGiftButton) forControlEvents:UIControlEventTouchUpInside];
    [self.giftButton setBackgroundColor:[UIColor db_defaultColor]];
    self.giftButton.layer.cornerRadius = self.giftButton.frame.size.height / 2;
    self.giftButton.layer.masksToBounds = YES;
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

- (void)reloadGiftButton{
    self.giftButton.enabled = [DBFriendGiftHelper sharedInstance].validData;
    self.giftButton.alpha = [DBFriendGiftHelper sharedInstance].validData ? 1.0 : 0.5;
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
