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
#import "UIActionSheet+BlocksKit.h"
#import "DBTextResourcesHelper.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
//#import "FBSDKShareDialog.h"

#import "UIView+RoundedCorners.h"

@interface DBSharePermissionViewController () <SocialManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet UILabel *promocodeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *promocodeLabel;

@property (weak, nonatomic) IBOutlet UIView *facebookShareView;
@property (weak, nonatomic) IBOutlet UILabel *facebookShareLabel;

@property (weak, nonatomic) IBOutlet UIView *vkShareView;
@property (weak, nonatomic) IBOutlet UILabel *vkShareLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintVkShareViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintVkShareViewTopSpace;

@property (weak, nonatomic) IBOutlet UIView *smsShareView;
@property (weak, nonatomic) IBOutlet UILabel *smsShareLabel;

@property (weak, nonatomic) IBOutlet UIButton *otherButton;


@property (nonatomic, strong) UIActionSheet *actionSheet;

@property (nonatomic, strong) SocialManager *socialManager;

@end

@implementation DBSharePermissionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(!self.screen)
        self.screen = SHARE_PERMISSION_SCREEN;
    
    [self.facebookShareView setRoundedCorners];
    self.facebookShareLabel.text = NSLocalizedString(@"Поделиться в Facebook", nil).uppercaseString;
    
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
    
    
    self.titleLabel.text = [DBShareHelper sharedInstance].titleShareScreen;
    self.titleLabel.textColor = [DBTextResourcesHelper db_shareScreenTextColor];
    
    self.descriptionLabel.text = [DBShareHelper sharedInstance].textShareScreen;
    self.descriptionLabel.textColor = [DBTextResourcesHelper db_shareScreenTextColor];

    self.socialManager = [SocialManager sharedManagerWithDelegate:self];
//    [self initializeActionViewSheet];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [GANHelper analyzeScreen:self.screen];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
//    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

//- (void)initializeActionViewSheet {
//    self.actionSheet = [UIActionSheet bk_actionSheetWithTitle:NSLocalizedString(@"Поделиться", nil)];
//    
//    if ([self.socialManager vkIsAvailable]) {
//        [self.actionSheet bk_addButtonWithTitle:@"Вконтакте" handler:^{
//            [self.socialManager shareVk];
//        }];
//    }
//    
//    [self.actionSheet bk_addButtonWithTitle:@"Facebook" handler:^{
//        [self.socialManager shareFacebook];
//    }];
//    [self.actionSheet bk_addButtonWithTitle:NSLocalizedString(@"Сообщение", nil) handler:^{
//        [self.socialManager shareMessage:self];
//    }];
//    [self.actionSheet bk_addButtonWithTitle:NSLocalizedString(@"Другое", nil) handler:^{
//        [self.socialManager shareOther:self.screen];
//    }];
//    [self.actionSheet bk_setCancelButtonWithTitle:NSLocalizedString(@"Отменить", nil) handler:^{
//        
//    }];
//}

- (IBAction)closeButtonClick:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [GANHelper analyzeEvent:@"close_click" category:self.screen];
}

- (IBAction)shareButtonClick:(id)sender{
    [GANHelper analyzeEvent:@"share_click" category:self.screen];
    
    [self.actionSheet showInView:self.view];
}

#pragma mark - SocialManagerDelegate
- (void)socialManagerDidEndFetchShareInfo {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.shareButton.enabled = YES;
}

- (void)socialManagerDidBeginFetchShareInfo {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.shareButton.enabled = NO;
}

#pragma mark - DBSettingsProtocol

+ (DBSettingsItem *)settingsItemForViewController:(UIViewController *)viewController {
    DBSettingsItem *item = [DBSettingsItem new];
    item.name =  @"shareVC";
    item.title =  NSLocalizedString(@"Рассказать друзьям", nil);
    item.iconName = @"share_icon";
    item.viewController = viewController;
    item.navigationType = DBSettingsItemNavigationPresent;
    return item;
}

+ (id<DBSettingsItemProtocol>)settingsItem {
    return [DBSharePermissionViewController settingsItemForViewController:[ViewControllerManager shareFriendInvitationViewController]];
}

- (id<DBSettingsItemProtocol>)settingsItem {
    return [DBSharePermissionViewController settingsItemForViewController:self];
}

@end
