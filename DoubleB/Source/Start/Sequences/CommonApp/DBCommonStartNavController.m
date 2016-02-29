//
//  DBCommonStartNavController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBCommonStartNavController.h"
#import "LaunchViewController.h"

#import "DBCompaniesManager.h"
#import "DBCompaniesViewController.h"

#import "DBCitiesManager.h"
#import "DBCitiesViewController.h"
#import "ApplicationManager.h"

#import "UIAlertView+BlocksKit.h"
#import "MBProgressHUD.h"

typedef NS_ENUM(NSInteger, DBCommonStartState) {
    DBCommonStartStateLaunch = 0,
    DBCommonStartStateCities,
    DBCommonStartStateCompanies,
    DBCommonStartStateMain
};

@interface DBCommonStartNavController ()<DBCompaniesViewControllerDelegate, DBCitiesViewControllerDelegate>
@property (nonatomic) DBCommonStartState state;

@property (strong, nonatomic) NSDate *startDate;
@end

@implementation DBCommonStartNavController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self needLaunchScreen]) {
        self.state = DBCommonStartStateLaunch;
    } else {
        [self moveNext];
    }
    
    self.startDate = [NSDate date];
}

- (BOOL)needLaunchScreen {
    BOOL result = [super needLaunchScreen];
    
    result = result || ![DBCompanyInfo sharedInstance].infoLoaded;
    
    return result;
}

- (void)additionalLaunchScreenActions {
    BOOL additionalActions = NO;
    if ([ApplicationConfig sharedInstance].hasCities) {
        if ([DBCitiesManager selectedCity]) {
            if ([ApplicationConfig sharedInstance].hasCompanies) {
                if ([DBCompaniesManager selectedCompany]) {
                    additionalActions = YES;
                }
            } else {
                additionalActions = YES;
            }
        }
    } else {
        if ([ApplicationConfig sharedInstance].hasCompanies) {
            if ([DBCompaniesManager selectedCompany]) {
                additionalActions = YES;
            }
        } else {
            additionalActions = YES;
        }
    }
    
    if (additionalActions) {
        [self fetchCompanyInfo];
    } else {
        [self moveNext];
    }
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

- (void)moveNext {
    if (self.state == DBCommonStartStateLaunch) {
        if ([ApplicationConfig sharedInstance].hasCities && ![DBCitiesManager selectedCity]) {
            [self moveToCities];
            return;
        } else {
            self.state = DBCommonStartStateCities;
        }
    }
    
    if (self.state == DBCommonStartStateCities) {
        if ([ApplicationConfig sharedInstance].hasCompanies && ![DBCompaniesManager selectedCompany]) {
            [self moveToCompanies];
            return;
        } else {
            self.state = DBCommonStartStateCompanies;
        }
    }
    
    if (self.state == DBCommonStartStateCompanies) {
        if ([DBCompanyInfo sharedInstance].infoLoaded) {
            [self moveToMain];
            [[DBCompanyInfo sharedInstance] updateInfo:nil];
            return;
        } else {
            [MBProgressHUD showHUDAddedTo:self.topViewController.view animated:YES];
            [[DBCompanyInfo sharedInstance] updateInfo:^(BOOL success) {
                [MBProgressHUD hideAllHUDsForView:self.topViewController.view animated:YES];
                if (success) {
                    [self moveToMain];
                }
            }];
        }
    }
}

- (void)moveToCities {
    DBCitiesViewController *citiesVC = [DBCitiesViewController new];
    citiesVC.delegate = self;
    citiesVC.mode = DBCitiesViewControllerModeChooseCity;
    
    [self setNavigationBarHidden:NO animated:YES];
    [self setViewControllers:@[citiesVC] animated:YES];
    self.state = DBCommonStartStateCities;
}

- (void)moveToCompanies {
    UIViewController<DBCompaniesViewControllerProtocol> *companiesVC = [DBCompaniesViewController new];
    [companiesVC setVCMode:DBCompaniesViewControllerModeChooseCompany];
    [companiesVC setVCDelegate:self];
    
    [self setNavigationBarHidden:NO animated:YES];
    [self setViewControllers:@[companiesVC] animated:YES];
    self.state = DBCommonStartStateCompanies;
}

- (void)moveToMain {
    if ([self.navDelegate respondsToSelector:@selector(db_startNavVCNeedsMoveToMain:)]) {
        double interval = [[NSDate date] timeIntervalSinceDate:self.startDate];
        [GANHelper analyzeTiming:@"Start_application" interval:@(interval) name:@"app_started"];
        
        self.state = DBCommonStartStateMain;
        [self.navDelegate db_startNavVCNeedsMoveToMain:self];
    }
}

#pragma mark - DBCitiesViewControllerDelegate

- (void)db_citiesViewControllerDidSelectCity:(DBUnifiedCity *)city {
    [[ApplicationManager sharedInstance] flushStoredCache];
    [DBCitiesManager selectCity:city];
    
    [self moveNext];
}

#pragma mark - DBCompaniesViewControllerDelegate

- (void)db_companiesVC:(DBCompaniesViewController *)controller didSelectCompany:(DBCompany *)company {
    [self moveNext];
}

@end
