//
//  ViewControllerManager.m
//  
//
//  Created by Balaban Alexander on 15/07/15.
//
//

#import "ViewControllerManager.h"

#pragma mark - General

@implementation ViewControllerManager

+ (nullable NSString *)valueFromPropertyListByKey:(nonnull NSString *)key {
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"ViewControllers.plist"];
    NSDictionary *viewControllersConfig = [NSDictionary dictionaryWithContentsOfFile:path];
    return [viewControllersConfig objectForKey:key];
}

@end


#pragma mark - Menu Controllers
#import "CategoriesAndPositionsTVController.h"
#import "CategoriesAndPositionsCVController.h"
#import "CategoriesTVController.h"
#import "PositionsTVController.h"
@implementation ViewControllerManager(MenuViewControllers)

+ (nonnull NSDictionary *)categoriesAndPositionsMenuViewControllerClasses {
    return @{
             @"default": [CategoriesAndPositionsTVController class],
             @"TableView": [CategoriesAndPositionsTVController class],
             @"CollectionView": [CategoriesAndPositionsCVController class],
             };
}

+ (Class<MenuListViewControllerProtocol> __nonnull)rootMenuViewController{
    NSString *menuControllersMode = [self valueFromPropertyListByKey:@"MenuViewControllers"];
    if([menuControllersMode isEqualToString:@"Nested"]){
        return [self categoriesViewController];
    } else {
        return [self categoriesAndPositionsViewController];
    }
}

+ (Class<MenuListViewControllerProtocol> __nonnull)categoriesViewController{
    Class<MenuListViewControllerProtocol> categoriesVCClass = [CategoriesTVController class];
    return categoriesVCClass;
}

+ (Class<MenuListViewControllerProtocol> __nonnull)positionsViewController{
    Class<MenuListViewControllerProtocol> positionsVCClass = [PositionsTVController class];
    return positionsVCClass;
}

+ (Class<MenuListViewControllerProtocol> __nonnull)categoriesAndPositionsViewController {
    Class<MenuListViewControllerProtocol> catAndPosVCClass = [self categoriesAndPositionsMenuViewControllerClasses][[self valueFromPropertyListByKey:@"MenuPositions"] ?: @"default"];
    return catAndPosVCClass;
}

@end


#pragma mark - Position
#import "PositionViewController1.h"
#import "PositionViewController2.h"
@implementation ViewControllerManager(PositionViewControllers)

+ (nonnull NSDictionary *)positionViewControllerClasses {
    return @{
             @"default": [PositionViewController1 class],
             @"Classic": [PositionViewController1 class],
             @"New": [PositionViewController2 class],
             };
}


+ (__nonnull Class<PositionViewControllerProtocol>)positionViewController {
    return [self positionViewControllerClasses][[self valueFromPropertyListByKey:@"Position"] ?: @"default"];
}

@end


#pragma mark - Launch
#import "LaunchViewController.h"
@implementation ViewControllerManager(LaunchViewControllers)

+ (nonnull NSDictionary *)launchViewControllerClasses {
    return @{
             @"default": [LaunchViewController class]
             };
}

+ (nonnull UIViewController *)launchViewController {
    Class launchViewController = [self launchViewControllerClasses][[ViewControllerManager valueFromPropertyListByKey:@"Launch"] ?: @"default"];
    return [launchViewController new];
}

@end


#pragma mark - Main
#import "DBTabBarController.h"
@implementation ViewControllerManager(MainViewControllers)

+ (nonnull NSDictionary *)mainViewControllerClasses {
    return @{
             @"default": [DBTabBarController class]
             };
}

+ (nonnull UIViewController *)mainViewController {
    Class mainViewController = [self mainViewControllerClasses][[self valueFromPropertyListByKey:@"Main"] ?: @"default"];
    return [mainViewController new];
}

@end
