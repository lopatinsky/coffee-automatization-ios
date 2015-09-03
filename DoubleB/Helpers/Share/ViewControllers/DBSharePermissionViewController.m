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

#import <FacebookSDK/FacebookSDK.h>
#import <FBSDKShareLinkContent.h>
#import "FBSDKShareDialog.h"
#import "MBProgressHUD.h"

#import "CAGradientLayer+Helper.h"

@interface DBSharePermissionViewController () <SocialManagerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *shareImageView;

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *logoLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@property (nonatomic, strong) UIActionSheet *actionSheet;

@property (nonatomic, strong) SocialManager *socialManager;

@end

@implementation DBSharePermissionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *imageName = [NSString stringWithFormat:@"share_%ld.jpg", (long)[UIScreen mainScreen].bounds.size.height];
    self.shareImageView.image = [UIImage imageNamed:imageName];
    
    self.logoImageView.hidden = YES;
    self.logoLabel.text = [DBCompanyInfo sharedInstance].applicationName;
    
    self.closeButton.imageView.image = [UIImage imageNamed:@"close_white.png"];
    
    self.shareButton.backgroundColor = [UIColor db_defaultColor];
    [self.shareButton setTitle:NSLocalizedString(@"Поделиться", nil) forState:UIControlStateNormal];
    
//    CAGradientLayer *gradient = [CAGradientLayer gradientForFrame:self.shareButton.bounds
//                                                        fromColor:[UIColor colorWithRed:175./255 green:231./255 blue:231./255 alpha:1.f]
//                                                            point:CGPointMake(0.5, 0.0)
//                                                          toColor:[UIColor colorWithRed:83./255 green:207./255 blue:205./255 alpha:1.f]
//                                                            point:CGPointMake(0.5, 1.0)];
//    [self.shareButton.layer addSublayer:gradient];
    self.shareButton.layer.cornerRadius = self.shareButton.frame.size.height / 2;
    self.shareButton.layer.masksToBounds = YES;
    self.shareButton.enabled = YES;
    
    [self.closeButton addTarget:self action:@selector(closeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.shareButton addTarget:self action:@selector(shareButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.titleLabel.text = [DBShareHelper sharedInstance].titleShareScreen;
    self.descriptionLabel.text = [DBShareHelper sharedInstance].textShareScreen;

    self.socialManager = [SocialManager sharedManagerWithDelegate:self];
    [self initializeActionViewSheet];
}

- (void)viewDidAppear:(BOOL)animated{
    [GANHelper analyzeScreen:self.screen];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)initializeActionViewSheet {
    self.actionSheet = [UIActionSheet bk_actionSheetWithTitle:NSLocalizedString(@"Поделиться", nil)];
    
    [self.actionSheet bk_addButtonWithTitle:@"Facebook" handler:^{
        [self.socialManager shareFacebook];
    }];
    [self.actionSheet bk_addButtonWithTitle:@"Vk" handler:^{
        [self.socialManager shareVk];
    }];
    [self.actionSheet bk_addButtonWithTitle:NSLocalizedString(@"Другие", nil) handler:^{
        [self.socialManager shareOther:self.screen];
    }];
    [self.actionSheet bk_setCancelButtonWithTitle:NSLocalizedString(@"Отменить", nil) handler:^{
        
    }];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

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

@end
