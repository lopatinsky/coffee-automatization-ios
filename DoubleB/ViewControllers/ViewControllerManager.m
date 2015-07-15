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

@implementation ViewControllerManager(Test)

+ (nonnull NSDictionary *)positionsViewControllerClasses {
    return @{
             @"default": [PositionsTableViewController class],
             @"TableView": [PositionsTableViewController class],
             @"CollectionView": [PositionsCollectionViewController class],
             };
}

@end

#pragma mark - Manager implementation
@implementation ViewControllerManager

+ (nonnull UIViewController<PositionsViewControllerDelegate> *)positionsViewController {
    Class positionsVCClass = [self positionsViewControllerClasses][[self valueFromPropertyListByKey:@"MenuPositions"] ?: @"default"];
    return [positionsVCClass new];
}

+ (nullable NSString *)valueFromPropertyListByKey:(nonnull NSString *)key {
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"ViewControllers.plist"];
    NSDictionary *viewControllersConfig = [NSDictionary dictionaryWithContentsOfFile:path];
    return [viewControllersConfig objectForKey:key];
}

@end
