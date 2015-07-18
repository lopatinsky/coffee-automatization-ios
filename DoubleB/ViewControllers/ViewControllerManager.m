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

#import "PositionViewController.h"
#import "DBPositionViewController.h"

@implementation ViewControllerManager(PositionViewControllers)

+ (nonnull NSDictionary *)positionViewControllerClasses {
    return @{
             @"default": [DBPositionViewController class],
             @"Classic": [DBPositionViewController class],
             @"New": [PositionViewController class],
             };
}

@end

#pragma mark - Manager implementation
@implementation ViewControllerManager

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
