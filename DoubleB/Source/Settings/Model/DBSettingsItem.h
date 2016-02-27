//
//  DBSettingsItem.h
//  DoubleB
//
//  Created by Balaban Alexander on 18/01/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DBSettingsItemBlock)(UIViewController *);

@protocol DBSettingsItemProtocol <NSObject>

- (NSString *)name;
- (NSString *)iconName;
- (NSString *)title;
- (NSString *)reachTitle;
- (NSString *)eventLabel;
- (UIViewController *)viewController;
- (NSDictionary *)params;
- (DBSettingsItemBlock *)block;

@end

typedef enum : NSUInteger {
    DBSettingsItemNavigationPresent,
    DBSettingsItemNavigationPush,
    DBSettingsItemNavigationBlock,
} DBSettingsItemNavigation;

@interface DBSettingsItem : NSObject <DBSettingsItemProtocol>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *reachTitle;
@property (nonatomic, strong) NSString *iconName;
@property (nonatomic, strong) NSString *eventLabel;
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, strong) UIView *view;
@property (nonatomic) DBSettingsItemNavigation navigationType;
@property (copy, nonatomic) DBSettingsItemBlock block;

@end
