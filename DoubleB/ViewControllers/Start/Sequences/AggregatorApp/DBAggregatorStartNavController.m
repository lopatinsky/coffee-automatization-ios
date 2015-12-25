//
//  DBUnifiedAppNavController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBAggregatorStartNavController.h"
#import "DBUnifiedAppManager.h"

#import "DBCitiesViewController.h"
#import "DBUnifiedMenuTableViewController.h"

#import "UIAlertView+BlocksKit.h"

typedef NS_ENUM(NSInteger, DBAggregatorStartState) {
    DBAggregatorStartStateLaunch = 0,
    DBAggregatorStartStateCities,
    DBAggregatorStartStateMain
};

@interface DBAggregatorStartNavController ()<DBCitiesViewControllerDelegate>
@property (nonatomic) DBAggregatorStartState state;
@end

@implementation DBAggregatorStartNavController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationBarHidden:YES animated:NO];
    
    if (![DBUnifiedAppManager sharedInstance].citiesLoaded) {
        self.state = DBAggregatorStartStateLaunch;
        UIViewController<DBLaunchViewControllerProtocol> *launchVC = [ViewControllerManager launchViewController];
        
        @weakify(self)
        [launchVC setExecutableBlock:^{
            @strongify(self)
            [self fetchCitiesOnLaunch];
        }];
        self.viewControllers = @[launchVC];
    } else {
        if ([DBUnifiedAppManager sharedInstance].cities.count <= 1) {
            [self moveToUnifiedMenu:NO];
        } else if (![DBUnifiedAppManager selectedCity]) {
            [self moveToCities:NO];
        } else {
            [self moveToUnifiedMenu:NO];
        }
    }
}

- (void)fetchCitiesOnLaunch {
    [[DBUnifiedAppManager sharedInstance] fetchCities:^(BOOL success) {
        if (success) {
            [self moveToCities:YES];
        } else {
            [[UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Ошибка", nil) message:NSLocalizedString(@"Проверьте соединение с интернетом и попробуйте ещё раз", nil)
                                  cancelButtonTitle:NSLocalizedString(@"Повторить", nil) otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                          [self fetchCitiesOnLaunch];
                                      });
                                  }] show];
        }
    }];
}

- (void)moveToCities:(BOOL)animated {
    [self setNavigationBarHidden:NO animated:animated];
    DBCitiesViewController *citiesVC = [DBCitiesViewController new];
    citiesVC.delegate = self;
    [self setViewControllers:@[citiesVC] animated:animated];
}

- (void)moveToUnifiedMenu:(BOOL)animated {
    [self setNavigationBarHidden:NO animated:animated];
    [self setViewControllers:@[[DBUnifiedMenuTableViewController new]] animated:animated];
}

#pragma mark - DBCitiesViewControllerDelegate
- (void)db_citiesViewControllerDidSelectCity:(DBCity *)city {
    [DBUnifiedAppManager selectCity:city];
    
    DBUnifiedMenuTableViewController *menuVC = [DBUnifiedMenuTableViewController new];
    menuVC.type = UnifiedMenu;
    [self pushViewController:menuVC animated:YES];
}

@end
