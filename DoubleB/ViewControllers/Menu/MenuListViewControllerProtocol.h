//
//  PositionsViewControllerDelegate.h
//  
//
//  Created by Balaban Alexander on 15/07/15.
//
//

#import <Foundation/Foundation.h>

@class DBMenuCategory;

@protocol MenuListViewControllerProtocol <NSObject>

@optional
// Initializer for root menu controller or mixed(Categories & Positions) controller
+ (instancetype)createViewController;

// Initializer for nested menu controllers
+ (instancetype)createWithMenuCategory:(DBMenuCategory *)category;

+ (NSDictionary *)preferences;
+ (void)setPreferences:(NSDictionary *)preferences;

@end
