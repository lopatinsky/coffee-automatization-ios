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
#import "DBStartNavController.h"

typedef NS_ENUM(NSInteger, RootState) {
    RootStateStart = 0,
    RootStateMain
};

typedef NS_ENUM(NSInteger, ApplicationType) {
    ApplicationTypeCommon = 0,
    ApplicationTypeProxy,
    ApplicationTypeAggregator,
    ApplicationTypeDemo
};

typedef NS_ENUM(NSInteger, ApplicationScreen) {
    ApplicationScreenRoot = 0,
    ApplicationScreenMenu,
    ApplicationScreenOrder,
    ApplicationScreenHistory,
    ApplicationScreenHistoryOrder,
    ApplicationScreenVenue
};

@interface ApplicationManager : NSObject<ManagerProtocol>
@property (nonatomic) ApplicationType applicationType;

+ (instancetype)sharedInstance;
+ (void)handlePush:(NSDictionary *)push;
+ (void)handleLocalPush:(UILocalNotification *)push;

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

@interface ApplicationManager(Start) <DBStartNavControllerDelegate>
- (UIViewController *)rootViewController;
- (void)fetchCompanyDependentInfo;
@end

@interface ApplicationManager(Controllers)
- (UIViewController *)mainViewController;
@end

@interface ApplicationManager(ScreenState)
- (void)moveToScreen:(ApplicationScreen)screen animated:(BOOL)animated;
- (void)moveToScreen:(ApplicationScreen)screen object:(id)object animated:(BOOL)animated;
@end

@interface ApplicationManager(Indexing)
+ (void)continueUserActivity:(NSUserActivity *)activity;
@end

@interface ApplicationManager(DemoApp)
- (UIViewController *)demoLoginViewController;
@end

@interface ApplicationManager(Review)
- (void)showReviewViewController:(NSString *)orderId;
@end

@interface ApplicationManager(AppConfig)
- (void)fetchAppConfiguration:(void(^)(BOOL success))callback;
- (void)reloadAppWithAppConfig;
@end