//
//  DBProxyStartNavController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBProxyStartNavController.h"
#import "LaunchViewController.h"
#import "DBCompaniesViewController.h"

#import "DBCompaniesManager.h"

#import "UIAlertView+BlocksKit.h"

typedef NS_ENUM(NSInteger, DBProxyStartState) {
    DBProxyStartStateLaunch = 0,
    DBProxyStartStateCompanies,
    DBCommonStartStateMain
};

@interface DBProxyStartNavController ()
@property (nonatomic) DBProxyStartState state;
@end

@implementation DBProxyStartNavController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([DBCompanyInfo sharedInstance].infoLoaded) {
        [self moveToMain];
    } else if ([[DBCompaniesManager sharedInstance] companiesLoaded] && [DBCompaniesManager sharedInstance].hasCompanies && ![DBCompaniesManager sharedInstance].companyIsChosen) {
        [self moveToCompanies:NO];
    } else {
        self.state = DBProxyStartStateLaunch;
        LaunchViewController *launchVC = [ViewControllerManager launchViewController];
        
        @weakify(self)
        launchVC.executableBlock = ^void() {
            @strongify(self)
            [self fetchCompanies];
        };
        self.viewControllers = @[launchVC];
    }
}

- (void)fetchCompanies {
    [[DBCompanyInfo sharedInstance] updateInfo:^(BOOL success) {
        if (success) {
            [self moveToCompanies:YES];
        } else {
            [[UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Ошибка", nil) message:NSLocalizedString(@"Проверьте соединение с интернетом и попробуйте ещё раз", nil)
                                  cancelButtonTitle:NSLocalizedString(@"Повторить", nil) otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                          [self fetchCompanies];
                                      });
                                  }] show];
        }
    }];
}

- (void)moveToCompanies:(BOOL)animated {
    DBCompaniesViewController *companiesVC = [ViewControllerManager companiesViewControllers];
//    companiesVC = 
    [self setViewControllers:@[companiesVC] animated:animated];
    
    self.state = DBProxyStartStateCompanies;
}

- (void)moveToMain {
    if ([self.navDelegate respondsToSelector:@selector(db_startNavVCNeedsMoveToMain:)]) {
        self.state = DBCommonStartStateMain;
        [self.navDelegate db_startNavVCNeedsMoveToMain:self];
    }
}

@end
