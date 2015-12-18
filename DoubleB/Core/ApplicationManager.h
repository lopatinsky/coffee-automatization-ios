//
//  ApplicationManager.h
//  
//
//  Created by Balaban Alexander on 28/07/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ManagerProtocol.h"
#import "MenuListViewControllerProtocol.h"

typedef NS_ENUM(NSInteger, RootState) {
    RootStateLaunch,
    RootStateMain,
    RootStateCompanies,
};

typedef NS_ENUM(NSInteger, ApplicationScreen) {
    ApplicationScreenRoot = 0,
    ApplicationScreenOrder,
    ApplicationScreenHistory,
    ApplicationScreenHistoryOrder
};

@interface ApplicationManager : NSObject<ManagerProtocol>
+ (instancetype)sharedInstance;
+ (void)handlePush:(NSDictionary *)push;
+ (void)handleLocalPush:(UILocalNotification *)push;

- (void)initializeVendorFrameworks;
- (void)startApplicationWithOptions:(NSDictionary *)launchOptions;

- (void)awakeFromNotification:(NSDictionary *)userInfo;
- (void)recieveNotification:(NSDictionary *)userInfo;

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

@interface ApplicationManager(Controllers)
- (UIViewController *)mainViewController;
- (Class<MenuListViewControllerProtocol>)mainMenuViewController;
@end

@interface ApplicationManager(ScreenState)
- (void)moveToScreen:(ApplicationScreen)screen animated:(BOOL)animated;
- (void)moveToScreen:(ApplicationScreen)screen object:(id)object animated:(BOOL)animated;
@end

@interface ApplicationManager(DemoApp)
- (UIViewController *)demoLoginViewController;
@end

@interface ApplicationManager(Review)
- (void)showReviewViewController:(NSString *)orderId;
@end