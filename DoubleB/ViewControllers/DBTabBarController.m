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
//#import "DBSharePermissionViewController.h"

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
        // New order vc
        DBNewOrderViewController *newOrderController = [DBClassLoader loadNewOrderViewController];
    
        newOrderController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Заказ", nil)
                                                                      image:[UIImage imageNamed:@"orders_icon_grey.png"]
                                                              selectedImage:[UIImage imageNamed:@"orsers_icon.png"]];
        [newOrderController.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -4)];
        [tabBarControllers addObject:[[UINavigationController alloc] initWithRootViewController:newOrderController]];
        
        // History vc
        DBOrdersTableViewController *ordersController = [DBOrdersTableViewController new];
        ordersController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"История", nil)
                                                                    image:[UIImage imageNamed:@"menu_icon_grey.png"]
                                                            selectedImage:[UIImage imageNamed:@"menu_icon.png"]];
        [ordersController.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -4)];
        [tabBarControllers addObject:[[UINavigationController alloc] initWithRootViewController:ordersController]];
        
        // Venues vc
        if(!([[DBCompanyInfo sharedInstance].deliveryTypes count] == 1 &&
           [[DBCompanyInfo sharedInstance] isDeliveryTypeEnabled:DeliveryTypeIdShipping])){
            DBVenuesTableViewController *venuesController = [DBVenuesTableViewController new];
            venuesController.mode = DBVenuesTableViewControllerModeList;
            venuesController.eventsCategory = VENUES_SCREEN;
            
            NSString *title = NSLocalizedString(@"Точки", nil);
            if([DBCompanyInfo sharedInstance].type == DBCompanyTypeCafe){
                NSUInteger venuesCount = [[Venue storedVenues] count];
                if(venuesCount == 1){
                    title = NSLocalizedString(@"Кофейня", nil);
                } else {
                    title = NSLocalizedString(@"Кофейни", nil);
                }
            }
            venuesController.tabBarItem = [[UITabBarItem alloc] initWithTitle:title
                                                                        image:[UIImage imageNamed:@"venues_icon_grey.png"]
                                                                selectedImage:[UIImage imageNamed:@"venues_icon.png"]];
            [venuesController.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -4)];
            [tabBarControllers addObject:[[UINavigationController alloc] initWithRootViewController:venuesController]];
        }
        
        self.tabBar.tintColor = [UIColor blackColor];
        self.viewControllers = tabBarControllers;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newOrderCreatedNotification:) name:kDBNewOrderCreatedNotification object:nil];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromRemoteNotification{
    self.selectedIndex = 1;
}

#pragma mark - DBNewOrderViewControllerDelegate

- (void)newOrderCreatedNotification:(NSNotification *)notification{
    self.selectedIndex = 1;
    
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
    
    //self.selectedIndex = 1;
    [UIAlertView bk_showAlertViewWithTitle:order.venue.title
                                   message:NSLocalizedString(@"Заказ отправлен. Мы вас ждем!", nil)
                         cancelButtonTitle:NSLocalizedString(@"OK", nil)
                         otherButtonTitles:nil
                                   handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                                       if(order.paymentType == PaymentTypeExtraType){
//                                           DBSharePermissionViewController *shareVC = [DBSharePermissionViewController new];
//                                           [self presentViewController:shareVC animated:YES completion:nil];
//                                       }
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
