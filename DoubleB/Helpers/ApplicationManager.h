//
//  ApplicationManager.h
//  
//
//  Created by Balaban Alexander on 28/07/15.
//
//

#import <Foundation/Foundation.h>
#import "MenuListViewControllerProtocol.h"

@interface ApplicationManager : NSObject
+ (nonnull UIViewController *)rootViewController;
+ (void)copyPlistWithName:(nonnull NSString *)plistName forceCopy:(BOOL)forceCopy;
+ (void)copyPlistsWithNames:(nonnull NSArray *)plistsNames forceCopy:(BOOL)forceCopy;
@end

@interface ApplicationManager(Initialization)
+ (void)initializeVendorFrameworks;
+ (void)initializeOrderFramework;
@end

@interface ApplicationManager(Appearance)
+ (void)applyBrandbookStyle;
@end

@interface ApplicationManager(Menu)
+ (nonnull Class<MenuListViewControllerProtocol>)rootMenuViewController;
@end