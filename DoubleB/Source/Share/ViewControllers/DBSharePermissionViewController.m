//
//  SharePermissionViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 12.01.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBSharePermissionViewController.h"
#import "UIViewController+ShareExtension.h"
#import "DBShareHelper.h"
#import "DBCompanyInfo.h"
#import "SocialManager.h"
#import "DBProgressBackgroundView.h"
#import "DBTextResourcesHelper.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
//#import "FBSDKShareDialog.h"

#import "DBPopupViewController.h"
#import "UIView+RoundedCorners.h"
#import "UIGestureRecognizer+BlocksKit.h"
#import "UIControl+BlocksKit.h"
#import "UIAlertView+BlocksKit.h"

@interface DBSharePermissionViewController () <DBSocialManagerDelegate, DBPopupViewControllerContent>
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet UILabel *promocodeTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *promocodeTextView;

@property (weak, nonatomic) IBOutlet UIView *facebookShareView;
@property (weak, nonatomic) IBOutlet UILabel *facebookShareLabel;

@property (weak, nonatomic) IBOutlet UIView *vkShareView;
@property (weak, nonatomic) IBOutlet UILabel *vkShareLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintVkShareViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintVkShareViewTopSpace;

@property (weak, nonatomic) IBOutlet UIView *smsShareView;
@property (weak, nonatomic) IBOutlet UILabel *smsShareLabel;

@property (weak, nonatomic) IBOutlet UIButton *otherButton;


@property (nonatomic, strong) DBProgressBackgroundView *progressView;

@property (nonatomic, strong) SocialManager *socialManager;

@end

@implementation DBSharePermissionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(!self.screen)
        self.screen = SHARE_PERMISSION_SCREEN;
    
    self.socialManager = [SocialManager sharedManager];
    self.socialManager.delegate = self;
    
    [self.facebookShareView setRoundedCorners];
    self.facebookShareLabel.text = NSLocalizedString(@"Поделиться в Facebook", nil).uppercaseString;
    
    self.promocodeTitleLabel.text = NSLocalizedString(@"Поделитесь своим промо-кодом", nil).uppercaseString;
    self.promocodeTextView.contentInset = UIEdgeInsetsMake(-5, 0, 0, 0);
    [self reload];
    
    [self.vkShareView setRoundedCorners];
    self.vkShareLabel.text = NSLocalizedString(@"Поделиться в Vk", nil).uppercaseString;
    if (![self.socialManager vkIsAvailable]) {
        self.constraintVkShareViewHeight.constant = 0;
        self.constraintVkShareViewTopSpace.constant = 0;
    }
    
    [self.smsShareView setRoundedCorners];
    self.smsShareView.backgroundColor = [UIColor db_defaultColor];
    self.smsShareLabel.text = NSLocalizedString(@"Поделиться через смс", nil).uppercaseString;
    
    [self.otherButton setTitle:NSLocalizedString(@"Другое", nil) forState:UIControlStateNormal];
    [self.otherButton setTitleColor:[UIColor db_defaultColor] forState:UIControlStateNormal];
    
    @weakify(self)
    [self.facebookShareView addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self)
        [self.socialManager shareFacebook];
    }]];
    
    [self.vkShareView addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self)
        [self.socialManager shareVk];
    }]];
    
    [self.smsShareView addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self)
        [self.socialManager shareMessage:self];
    }]];
    
    [self.otherButton bk_addEventHandler:^(id sender) {
        [self.socialManager shareOther:self.screen];
    } forControlEvents:UIControlEventTouchUpInside];

    self.progressView = [DBProgressBackgroundView new];
}

- (void)viewWillAppear:(BOOL)animated {
    if (![DBShareHelper sharedInstance].infoLoaded) {
        [self.progressView showOnView:self.view color:[UIColor whiteColor]];
        [[DBShareHelper sharedInstance] fetchShareInfo:^(BOOL success) {
            if (success) {
                [self reload];
                [self.progressView hide];
            } else {
                [self.progressView stopAnimating];
                [self.progressView showMessage:NSLocalizedString(@"Нет данных", nil)];
            }
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [GANHelper analyzeScreen:self.screen];
}

- (void)reload {
    self.promocodeTextView.text = [DBShareHelper sharedInstance].promoCode;
    [self configTitle];
}

- (void)configTitle {
    NSMutableString *text = [[NSMutableString alloc] initWithString:[DBShareHelper sharedInstance].titleShareScreen];
    [text appendString:@"\n\n"];

    [text appendString:[DBShareHelper sharedInstance].textShareScreen];
    
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:text];
    [attrText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue" size:17.f] range:NSMakeRange(0, [DBShareHelper sharedInstance].titleShareScreen.length)];
    
    self.descriptionLabel.attributedText = attrText;
    self.descriptionLabel.textColor = [DBTextResourcesHelper db_shareScreenTextColor];
}


#pragma mark - DBSocialManagerDelegate
- (UIViewController *)db_socialManagerContainer {
    return self;
}

#pragma mark - DBSettingsProtocol

+ (DBSettingsItem *)settingsItemForViewController:(UIViewController<DBSettingsProtocol, DBPopupViewControllerContent> *)viewController settingsController:(DBBaseSettingsTableViewController*)settingsVC{
    DBSettingsItem *item = [DBSettingsItem new];
    item.name =  @"shareVC";
    item.title =  NSLocalizedString(@"Рассказать друзьям", nil);
    item.iconName = @"share_icon";
    item.block = ^(UIViewController *vc){
        [DBPopupViewController presentController:viewController inContainer:vc mode:DBPopupVCAppearanceModeHeader];
    };
    
    item.navigationType = DBSettingsItemNavigationPresent;
    return item;
}

+ (id<DBSettingsItemProtocol>)settingsItem:(DBBaseSettingsTableViewController *)settingsVC{
    return [DBSharePermissionViewController settingsItemForViewController:[ViewControllerManager shareFriendInvitationViewController] settingsController:settingsVC];
}

- (id<DBSettingsItemProtocol>)settingsItem:(DBBaseSettingsTableViewController *)settingsVC {
    return [DBSharePermissionViewController settingsItemForViewController:self settingsController:settingsVC];
}

@end
