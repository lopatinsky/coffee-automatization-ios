//
//  DBUnifiedAppNavController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBAggregatorStartNavController.h"
#import "DBCitiesManager.h"
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
}

- (void)fetchCitiesOnLaunch {
    [[DBCitiesManager sharedInstance] fetchCities:^(BOOL success) {
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



#pragma mark - DBCitiesViewControllerDelegate
- (void)db_citiesViewControllerDidSelectCity:(DBUnifiedCity *)city {
    [DBCitiesManager selectCity:city];
    [[DBUnifiedAppManager sharedInstance] fetchMenu:nil];
    [[DBUnifiedAppManager sharedInstance] fetchVenues:nil];
    
    DBUnifiedMenuTableViewController *menuVC = [DBUnifiedMenuTableViewController new];
    menuVC.type = UnifiedVenue;
    [self pushViewController:menuVC animated:YES];
}

@end
