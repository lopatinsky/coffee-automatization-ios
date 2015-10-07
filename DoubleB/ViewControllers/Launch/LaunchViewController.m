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

@interface LaunchViewController ()
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

@end
