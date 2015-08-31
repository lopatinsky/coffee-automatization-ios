//
//  StartViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 25.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "LaunchViewController.h"
#import "DBTabBarController.h"
#import "DBCompaniesViewController.h"
#import "AppDelegate.h"
#import "ApplicationManager.h"
#import "DBCompaniesManager.h"
#import "NetworkManager.h"

@interface LaunchViewController ()<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UIView *tipView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation LaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *launchScreenName = [NSString stringWithFormat:@"launch_%.f.jpg", [UIScreen mainScreen].bounds.size.height];
    UIImage *image = [UIImage imageNamed:launchScreenName];
    
    if(!image){
        launchScreenName = [NSString stringWithFormat:@"launch_%.f.png", [UIScreen mainScreen].bounds.size.height];
        image = [UIImage imageNamed:launchScreenName];
    }
    
    self.backImageView.image = image;
    
    self.titleLabel.text = NSLocalizedString(@"Настройка приложения", nil);
}

- (void)viewWillAppear:(BOOL)animated{
    [self.activityIndicator startAnimating];
    
    [GANHelper analyzeScreen:LAUNCH_PLACEHOLDER_SCREEN];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)firstLaunchNecessaryInfoLoadSuccessNotification:(NSNotification *)notification {
    [GANHelper analyzeEvent:@"preload_success" category:LAUNCH_PLACEHOLDER_SCREEN];
    
    UIWindow *window = [(AppDelegate *)[[UIApplication sharedApplication] delegate] window];
    
    if ([window.rootViewController isKindOfClass:[LaunchViewController class]]) {
        window.rootViewController = [ViewControllerManager mainViewController];
    }
}

- (void)firstLaunchNecessaryInfoLoadFailureNotification:(NSNotification *)notification{
    [GANHelper analyzeEvent:@"preload_failed" category:LAUNCH_PLACEHOLDER_SCREEN];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"Не удается настроить приложение, поскольку отсутствует интернет-соединение"
                                                   delegate:self
                                          cancelButtonTitle:@"Попробовать еще раз"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    [GANHelper analyzeEvent:@"try_again_click" category:LAUNCH_PLACEHOLDER_SCREEN];
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[NetworkManager sharedManager] addUniqueOperation:NetworkOperationFetchCompanyInfo];
//    });
}

@end
