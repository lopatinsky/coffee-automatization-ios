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

@property (strong, nonatomic) NSDate *startDate;
@end

@implementation DBAggregatorStartNavController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self needLaunchScreen]) {
        self.state = DBAggregatorStartStateLaunch;
    } else {
        [self moveToMain];
    }
    
    self.startDate = [NSDate date];
}

- (BOOL)needLaunchScreen {
    BOOL result = [super needLaunchScreen];
    
    result = result || ([ApplicationConfig sharedInstance].hasCities && ![DBCitiesManager selectedCity]);
    
    return result;
}

- (void)additionalLaunchScreenActions {
    [self fetchCitiesOnLaunch];
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
    DBCitiesViewController *citiesVC = [DBCitiesViewController new];
    citiesVC.delegate = self;
    citiesVC.mode = DBCitiesViewControllerModeChooseCity;
    
    [self setNavigationBarHidden:NO animated:animated];
    [self setViewControllers:@[citiesVC] animated:animated];
}

- (void)moveToMain {
    if ([self.navDelegate respondsToSelector:@selector(db_startNavVCNeedsMoveToMain:)]) {
        double interval = [[NSDate date] timeIntervalSinceDate:self.startDate];
        [GANHelper analyzeTiming:@"Start_application" interval:@(interval) name:@"app_started"];
        
        self.state = DBAggregatorStartStateMain;
        [self.navDelegate db_startNavVCNeedsMoveToMain:self];
    }
}

#pragma mark - DBCitiesViewControllerDelegate
- (void)db_citiesViewControllerDidSelectCity:(DBUnifiedCity *)city {
    [DBCitiesManager selectCity:city];
    [self moveToMain];
}

@end
