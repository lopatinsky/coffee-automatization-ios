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

@property (nonatomic, readonly) BOOL allInfo;
- (void)updateAllInfo:(void(^)(BOOL success))callback;

+ (UIViewController *)rootViewController;
+ (void)copyPlistWithName:(NSString *)plistName forceCopy:(BOOL)forceCopy;
+ (void)copyPlistsWithNames:(NSArray *)plistsNames forceCopy:(BOOL)forceCopy;
@end

@interface ApplicationManager(Initialization)
+ (void)initializeVendorFrameworks;
+ (void)initializeOrderFramework;
@end

@interface ApplicationManager(Appearance)
+ (void)applyBrandbookStyle;
@end

@interface ApplicationManager(Menu)
+ (Class<MenuListViewControllerProtocol>)rootMenuViewController;
@end

@interface ApplicationManager(DemoApp)
+ (UIViewController *)demoLoginViewController;
@end