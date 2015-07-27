//
//  ViewControllerManager.m
//  
//
//  Created by Balaban Alexander on 15/07/15.
//
//

#import "ViewControllerManager.h"

#pragma mark - Dependency declarations
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

@end

#import "PositionViewController2.h"
#import "PositionViewController1.h"

@implementation ViewControllerManager(PositionViewControllers)

+ (nonnull NSDictionary *)positionViewControllerClasses {
    return @{
             @"default": [PositionViewController1 class],
             @"Classic": [PositionViewController1 class],
             @"New": [PositionViewController2 class],
             };
}

@end

#import "LaunchViewController.h"
@implementation ViewControllerManager(LaunchViewControllers)

+ (nonnull NSDictionary *)launchViewControllerClasses {
    return @{
             @"default": [LaunchViewController class]
             };
}

@end

#pragma mark - Manager implementation
@implementation ViewControllerManager

+ (nonnull UIViewController *)launchViewController {
    Class launchViewController = [self launchViewControllerClasses][[self valueFromPropertyListByKey:@"Launch"] ?: @"default"];
    return [launchViewController new];
}

+ (nonnull UIViewController<PositionsViewControllerProtocol> *)positionsViewController {
    Class<PositionsViewControllerProtocol> positionsVCClass = [self positionsViewControllerClasses][[self valueFromPropertyListByKey:@"MenuPositions"] ?: @"default"];
    return [positionsVCClass createViewController];
}

+ (__nonnull Class<PositionViewControllerProtocol>)positionViewController {
    return [self positionViewControllerClasses][[self valueFromPropertyListByKey:@"Position"] ?: @"default"];
}

+ (nullable NSString *)valueFromPropertyListByKey:(nonnull NSString *)key {
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"ViewControllers.plist"];
    NSDictionary *viewControllersConfig = [NSDictionary dictionaryWithContentsOfFile:path];
    return [viewControllersConfig objectForKey:key];
}

@end
