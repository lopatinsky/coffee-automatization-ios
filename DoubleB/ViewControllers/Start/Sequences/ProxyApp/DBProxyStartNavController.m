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

#import "MBProgressHUD.h"

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
    
    [self setNavigationBarHidden:YES animated:NO];
    
    if ([DBCompanyInfo sharedInstance].infoLoaded) {
        [self moveToMain];
        [[DBCompaniesManager sharedInstance] requestCompanies:nil];
        [[DBCompanyInfo sharedInstance] updateInfo:nil];
    } else if ([[DBCompaniesManager sharedInstance] companiesLoaded] && [DBCompaniesManager sharedInstance].hasCompanies && ![DBCompaniesManager sharedInstance].companyIsChosen) {
        [self moveToCompanies:NO];
        [[DBCompaniesManager sharedInstance] requestCompanies:nil];
    } else {
        self.state = DBProxyStartStateLaunch;
        UIViewController<DBLaunchViewControllerProtocol> *launchVC = [ViewControllerManager launchViewController];
        
        @weakify(self)
        [launchVC setExecutableBlock:^{
            @strongify(self)
            [self fetchCompanies];
        }];
        self.viewControllers = @[launchVC];
    }
}

- (void)fetchCompanies {
    [[DBCompaniesManager sharedInstance] requestCompanies:^(BOOL success, NSArray *companies) {
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
    UIViewController<DBCompaniesViewControllerProtocol> *companiesVC = [DBCompaniesViewController new];
    
    @weakify(self)
    [companiesVC setFinalBlock:^{
        @strongify(self)
        
        // Get selected company
        DBCompany *selectedCompany = [DBCompaniesManager selectedCompany];
        
        [[ApplicationManager sharedInstance] flushStoredCache];
        
        [DBCompaniesManager selectCompany:selectedCompany];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[DBCompanyInfo sharedInstance] updateInfo:^(BOOL success) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            [self moveToMain];
        }];
        [[ApplicationManager sharedInstance] fetchCompanyDependentInfo];
    }];
    
    [self setNavigationBarHidden:NO animated:animated];
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
