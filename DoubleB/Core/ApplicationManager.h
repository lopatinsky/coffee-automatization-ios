//
//  ApplicationManager.h
//  
//
//  Created by Balaban Alexander on 28/07/15.
//
//

#import <Foundation/Foundation.h>
#import "ManagerProtocol.h"
#import "MenuListViewControllerProtocol.h"

@interface ApplicationManager : NSObject<ManagerProtocol>
+ (instancetype)sharedInstance;

+ (void)copyPlistWithName:(NSString *)plistName forceCopy:(BOOL)forceCopy;
+ (void)copyPlistsWithNames:(NSArray *)plistsNames forceCopy:(BOOL)forceCopy;
@end

@interface ApplicationManager(Initialization)
+ (void)initializeVendorFrameworks;
+ (void)initializeOrderFramework:(NSDictionary *)launchOptions;
@end

@interface ApplicationManager(Appearance)
+ (void)applyBrandbookStyle;
@end

@interface ApplicationManager(Start)
+ (UIViewController *)rootViewController;
@end

@interface ApplicationManager(Menu)
+ (Class<MenuListViewControllerProtocol>)rootMenuViewController;
@end

@interface ApplicationManager(DemoApp)
+ (UIViewController *)demoLoginViewController;
@end