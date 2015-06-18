//
//  DBTabBarController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 13.01.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBTabBarController.h"
#import "DBPositionsViewController.h"
#import "DBOrdersTableViewController.h"
#import "DBVenuesTableViewController.h"
#import "DBOrderViewController.h"
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
        DBNewOrderViewController *newOrderController = [DBNewOrderViewController new];
    
        newOrderController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Заказ", nil)
                                                                      image:[UIImage imageNamed:@"orders_icon_grey.png"]
                                                              selectedImage:[UIImage imageNamed:@"orsers_icon.png"]];
        [newOrderController.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -4)];
        
        DBOrdersTableViewController *ordersController = [DBOrdersTableViewController new];
        ordersController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"История", nil)
                                                                    image:[UIImage imageNamed:@"menu_icon_grey.png"]
                                                            selectedImage:[UIImage imageNamed:@"menu_icon.png"]];
        [ordersController.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -4)];
        
        DBVenuesTableViewController *venuesController = [DBVenuesTableViewController new];
        venuesController.eventsCategory = VENUES_SCREEN;
        venuesController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Точки", nil)
                                                                    image:[UIImage imageNamed:@"venues_icon_grey.png"]
                                                            selectedImage:[UIImage imageNamed:@"venues_icon.png"]];
        [venuesController.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -4)];
        
        self.tabBar.tintColor = [UIColor blackColor];
        self.viewControllers = @[[[UINavigationController alloc] initWithRootViewController:newOrderController],
                                 [[UINavigationController alloc] initWithRootViewController:ordersController],
                                 [[UINavigationController alloc] initWithRootViewController:venuesController]];
        
        self.delegate = self;
    }
    return self;
}

- (void)awakeFromRemoteNotification{
    self.selectedIndex = 1;
}

#pragma mark - DBNewOrderViewControllerDelegate

- (void)newOrderViewController:(DBNewOrderViewController *)controller didFinishOrder:(Order *)order{
    self.selectedIndex = 1;
    
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


#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    NSString *category = @"";
    switch (tabBarController.selectedIndex) {
        case 0:
            category = @"Menu_screen";
            break;
        case 1:
            category = @"Orders_screen";
            break;
        case 2:
            category = @"Coffee_houses_screen";
            break;
        default:
            break;
    }
    
    NSString *event = @"";
    switch ([tabBarController.viewControllers indexOfObject:viewController]) {
        case 0:
            event = @"footer_menu_click";
            break;
        case 1:
            event = @"footer_orders_click";
            break;
        case 2:
            event = @"footer_coffee_houses_click";
            break;
        default:
            break;
    }
    [GANHelper analyzeEvent:event category:VENUES_SCREEN];
        
    return YES;
}

@end
