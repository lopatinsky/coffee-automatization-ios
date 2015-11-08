//
//  DBCommonStartNavController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBCommonStartNavController.h"
#import "LaunchViewController.h"

#import "UIAlertView+BlocksKit.h"

typedef NS_ENUM(NSInteger, DBCommonStartState) {
    DBCommonStartStateLaunch = 0,
    DBCommonStartStateCities,
    DBCommonStartStateMain
};

@interface DBCommonStartNavController ()
@property (nonatomic) DBCommonStartState state;

@property (strong, nonatomic) UIAlertView *alertView;
@end

@implementation DBCommonStartNavController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([DBCompanyInfo sharedInstance].infoLoaded) {
        [self moveToMain];
    } else {
        self.state = DBCommonStartStateLaunch;
        LaunchViewController *launchVC = [ViewControllerManager launchViewController];
        
        @weakify(self)
        launchVC.executableBlock = ^void() {
            @strongify(self)
            [self fetchCompanyInfo];
        };
        self.viewControllers = @[launchVC];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)fetchCompanyInfo {
    [[DBCompanyInfo sharedInstance] updateInfo:^(BOOL success) {
        if (success) {
            [self moveToMain];
        } else {
            [[UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Ошибка", nil) message:NSLocalizedString(@"Проверьте соединение с интернетом и попробуйте ещё раз", nil)
                                  cancelButtonTitle:NSLocalizedString(@"Повторить", nil) otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                          [self fetchCompanyInfo];
                                      });
                                  }] show];
        }
    }];
}

- (void)moveToMain {
    if ([self.navDelegate respondsToSelector:@selector(db_startNavVCNeedsMoveToMain:)]) {
        self.state = DBCommonStartStateMain;
        [self.navDelegate db_startNavVCNeedsMoveToMain:self];
    }
}


@end
