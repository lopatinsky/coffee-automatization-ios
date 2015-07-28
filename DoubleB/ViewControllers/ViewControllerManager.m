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


#pragma mark - Positions
#import "PositionsTableViewController.h"
#import "PositionsCollectionViewController.h"
@implementation ViewControllerManager(PositionsViewControllers)

+ (nonnull NSDictionary *)positionsViewControllerClasses {
    return @{
             @"default": [PositionsTableViewController class],
             @"TableView": [PositionsTableViewController class],
             @"CollectionView": [PositionsCollectionViewController class],
             };
}

+ (nonnull UIViewController<PositionsViewControllerProtocol> *)positionsViewController {
    Class<PositionsViewControllerProtocol> positionsVCClass = [self positionsViewControllerClasses][[self valueFromPropertyListByKey:@"MenuPositions"] ?: @"default"];
    return [positionsVCClass createViewController];
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
