//
//  DBTabBarController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 13.01.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBTabBarController.h"
#import "CategoriesAndPositionsTVController.h"
#import "DBOrdersTableViewController.h"
#import "DBVenuesTableViewController.h"
#import "DBOrderViewController.h"
#import "DBCompanyInfo.h"
#import "DBShareHelper.h"
#import "CompanyNewsManager.h"

#import "UIAlertView+BlocksKit.h"
#import "Order.h"
#import "Venue.h"

@implementation DBTabBarController

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static DBTabBarController *instance = nil;
    dispatch_once(&once, ^{ instance = [DBTabBarController new]; });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSMutableArray *tabBarControllers = [NSMutableArray new];
        
        if ([self tabAtIndexEnabled:0]){
            [tabBarControllers addObject:[self firstTabVC]];
        }
        
        if ([self tabAtIndexEnabled:1]){
            [tabBarControllers addObject:[self secondTabVC]];
        }
        
        if ([self tabAtIndexEnabled:2]){
            [tabBarControllers addObject:[self thirdTabVC]];
        }
        
        self.tabBar.tintColor = [UIColor blackColor];
        self.viewControllers = tabBarControllers;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newOrderCreatedNotification:) name:kDBNewOrderCreatedNotification object:nil];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[CompanyNewsManager sharedManager] fetchUpdates];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)tabAtIndexEnabled:(NSUInteger)index {
    BOOL result = NO;
    
    if(index == 0)
        result = YES;
    
    if(index == 1)
        result = YES;
    
    if(index == 2){
        result = !([[DBCompanyInfo sharedInstance].deliveryTypes count] == 1 &&
                   [[DBCompanyInfo sharedInstance] isDeliveryTypeEnabled:DeliveryTypeIdShipping]);
        
        if([[DBCompanyInfo sharedInstance].bundleName.lowercaseString isEqualToString:@"osteriabianka"]){
            result = NO;
        }
    }
    
    return result;
}

- (UIViewController *)firstTabVC {
    DBNewOrderViewController *newOrderController = [DBClassLoader loadNewOrderViewController];
    
    newOrderController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Заказ", nil)
                                                                  image:[UIImage imageNamed:@"orders_icon_grey.png"]
                                                          selectedImage:[UIImage imageNamed:@"orsers_icon.png"]];
    [newOrderController.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -4)];
    
    UINavigationController *newOrderNavController = [[UINavigationController alloc] initWithRootViewController:newOrderController];
    
    //TODO: Rewrite normal logic for screen sequence management
    UIViewController<MenuListViewControllerProtocol> *menuVC = [[ApplicationManager rootMenuViewController] createViewController];
    menuVC.hidesBottomBarWhenPushed = YES;
    [newOrderNavController pushViewController:menuVC animated:NO];
    
    return newOrderNavController;
}

- (UIViewController *)secondTabVC {
    DBOrdersTableViewController *ordersController = [DBOrdersTableViewController new];
    ordersController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"История", nil)
                                                                image:[UIImage imageNamed:@"menu_icon_grey.png"]
                                                        selectedImage:[UIImage imageNamed:@"menu_icon.png"]];
    [ordersController.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -4)];
    
    return [[UINavigationController alloc] initWithRootViewController:ordersController];
}

- (UIViewController *)thirdTabVC {
    DBVenuesTableViewController *venuesController = [DBVenuesTableViewController new];
    venuesController.mode = DBVenuesTableViewControllerModeList;
    venuesController.eventsCategory = VENUES_SCREEN;
    
    venuesController.tabBarItem = [[UITabBarItem alloc] initWithTitle:[DBTextResourcesHelper db_venuesTitleString]
                                                                image:[UIImage imageNamed:@"venues_icon_grey.png"]
                                                        selectedImage:[UIImage imageNamed:@"venues_icon.png"]];
    [venuesController.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -4)];
    return [[UINavigationController alloc] initWithRootViewController:venuesController];
}

- (void)moveToStartState {
    for(UIViewController *controller in self.viewControllers){
        if([controller isKindOfClass:[UINavigationController class]]){
            [((UINavigationController*)controller) popToRootViewControllerAnimated:NO];
        }
    }
    
    self.selectedViewController = [self.viewControllers objectAtIndex:0];
}

- (void)awakeFromRemoteNotification{
    self.selectedIndex = 1;
}

#pragma mark - DBNewOrderViewControllerDelegate

- (void)newOrderCreatedNotification:(NSNotification *)notification{
    self.selectedViewController = [self.viewControllers objectAtIndex:1];
    
    Order *order = notification.object;
    for(UIViewController *controller in self.viewControllers){
        if([controller isKindOfClass:[UINavigationController class]]){
            UINavigationController *navController = (UINavigationController *)controller;
            [navController popToRootViewControllerAnimated:NO];
            
            UIViewController *topVC = navController.topViewController;
            if([topVC isKindOfClass:[DBOrdersTableViewController class]]){
                DBOrderViewController *orderVC = [[DBOrderViewController alloc] init];
                orderVC.hidesBottomBarWhenPushed = YES;
                orderVC.scrollContentToBottom = YES;
                orderVC.order = order;
                [navController pushViewController:orderVC animated:NO];
            }
        }
    }
    
    [UIAlertView bk_showAlertViewWithTitle:order.venueName
                                   message:NSLocalizedString(@"Заказ отправлен. Мы вас ждем!", nil)
                         cancelButtonTitle:NSLocalizedString(@"OK", nil)
                         otherButtonTitles:nil
                                   handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                       // Show suggestion to share
                                       if ([DBShareHelper sharedInstance].shareSuggestionIsAvailable) {
                                           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                               [[DBShareHelper sharedInstance] showShareSuggestion:YES];
                                           });
                                       }
                                   }];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex{
    NSString *category = @"";
    switch (self.selectedIndex) {
        case 0:
            category = MENU_SCREEN;
            break;
        case 1:
            category = HISTORY_SCREEN;
            break;
        case 2:
            category = VENUES_SCREEN;
            break;
        default:
            break;
    }
    
    NSString *event = @"";
    switch (selectedIndex) {
        case 0:
            event = @"footer_order_click";
            break;
        case 1:
            event = @"footer_history_click";
            break;
        case 2:
            event = @"footer_venues_click";
            break;
        default:
            break;
    }
    
    [GANHelper analyzeEvent:event category:category];
}

@end
