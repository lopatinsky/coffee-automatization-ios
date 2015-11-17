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

typedef enum : NSUInteger {
    RootStateLaunch,
    RootStateMain,
    RootStateCompanies,
} RootState;

@interface ApplicationManager : NSObject<ManagerProtocol>
+ (instancetype)sharedInstance;
+ (void)handlePush:(NSDictionary *)push;

- (void)initializeVendorFrameworks;
- (void)startApplicationWithOptions:(NSDictionary *)launchOptions;

- (void)fetchCompanyDependentInfo;
@end

@interface ApplicationManager(Plist)
+ (void)copyPlistWithName:(NSString *)plistName forceCopy:(BOOL)forceCopy;
+ (void)copyPlistsWithNames:(NSArray *)plistsNames forceCopy:(BOOL)forceCopy;
@end

@interface ApplicationManager(Appearance)
+ (void)applyBrandbookStyle;
@end

@interface ApplicationManager(Start)
- (RootState)currentState;
- (UIViewController *)rootViewController;
@end

@interface ApplicationManager(Menu)
- (Class<MenuListViewControllerProtocol>)rootMenuViewController;
@end

@interface ApplicationManager(DemoApp)
- (UIViewController *)demoLoginViewController;
@end

@interface ApplicationManager(Review)
- (void)showReviewViewController:(NSString *)orderId;
@end