//
//  ViewControllerManager.h
//  
//
//  Created by Balaban Alexander on 15/07/15.
//
//

#import <Foundation/Foundation.h>
#import "MenuListViewControllerProtocol.h"
#import "PositionViewControllerProtocol.h"

@interface ViewControllerManager : NSObject
@end

@interface ViewControllerManager(MenuViewControllers)
+ (Class<MenuListViewControllerProtocol> __nonnull)rootMenuViewController;

+ (Class<MenuListViewControllerProtocol> __nonnull)categoriesViewController;
+ (Class<MenuListViewControllerProtocol> __nonnull)positionsViewController;
+ (Class<MenuListViewControllerProtocol> __nonnull)categoriesAndPositionsViewController;
@end

@interface ViewControllerManager(PositionViewControllers)
+ (__nonnull Class<PositionViewControllerProtocol>)positionViewController;
@end

@interface ViewControllerManager(LaunchViewControllers)
+ (nonnull UIViewController *)launchViewController;
@end

@interface ViewControllerManager(MainViewControllers)
+ (nonnull UIViewController *)mainViewController;
@end

@interface ViewControllerManager(NewsViewControllers)
+ (nonnull UIViewController *)newsViewController;
@end

@interface ViewControllerManager(PromocodeViewControllers)
+ (nonnull UIViewController *)promocodeViewControllers;
@end