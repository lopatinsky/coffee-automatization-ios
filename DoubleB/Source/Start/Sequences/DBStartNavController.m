//
//  DBStartNavController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBStartNavController.h"
#import "LaunchViewController.h"
#import "DBServerAPI.h"

#import "UIAlertView+BlocksKit.h"

@implementation DBStartNavController

- (instancetype)initWithDelegate:(id<DBStartNavControllerDelegate>)navDelegate {
    self = [super init];
    
    _navDelegate = navDelegate;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationBarHidden:YES animated:NO];
    
    if ([self needLaunchScreen]) {
        LaunchViewController *launchVC = [LaunchViewController new];
        
        @weakify(self)
        launchVC.executionBlock = ^{
            @strongify(self)
            [self fetchAppConfiguretion];
        };
        self.viewControllers = @[launchVC];
    } else {
        UIColor *oldColor = [ApplicationManager applicationColor];
        [ApplicationConfig update:^(BOOL success) {
            if (success) {
                if (![oldColor isEqual:[ApplicationManager applicationColor]]) {
                    [self.navDelegate db_startNavVCNeedsMoveToMain:self];
                }
            }
        }];
    }
}

- (void)fetchAppConfiguretion {
    [ApplicationConfig update:^(BOOL success) {
        if (success) {
            [self additionalLaunchScreenActions];
        } else {
            [[UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Ошибка", nil) message:NSLocalizedString(@"Проверьте соединение с интернетом и попробуйте ещё раз", nil)
                                  cancelButtonTitle:NSLocalizedString(@"Повторить", nil) otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                          [self fetchAppConfiguretion];
                                      });
                                  }] show];
        }
    }];
}

- (BOOL)needLaunchScreen {
    return [ApplicationConfig remoteConfig] == nil;
}

- (void)additionalLaunchScreenActions {
    
}

@end
