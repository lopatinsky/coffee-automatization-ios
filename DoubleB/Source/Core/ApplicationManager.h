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
    ApplicationTypeAggregator
};

typedef NS_ENUM(NSInteger, ApplicationScreen) {
    ApplicationScreenRoot = 0,
    ApplicationScreenMenu,
    ApplicationScreenOrder,
    ApplicationScreenHistory,
    ApplicationScreenHistoryOrder,
    ApplicationScreenVenue,
    ApplicationScreenUnified
};

typedef NS_ENUM(NSInteger, DBNOModules) {
    DBNOModulesDeliveryType = 0,
    DBNOModulesTime,
    DBNOModulesComment
};

extern NSString *const kDBApplicationConfigDidLoadNotification;

/**
 * Configuration for application
 */
@interface ApplicationConfig : NSObject
+ (instancetype)sharedInstance;

+ (void)update:(void (^)(BOOL success))callback;

// LOCAL
+ (id)objectFromPropertyListByName:(NSString *)name;
+ (id)objectFromApplicationPreferencesByName:(NSString *)name;

+ (ApplicationType)db_appType;
+ (NSString *)db_bundleName;

+ (NSString *)db_AppBaseUrl;
+ (id)db_AppDefaultColor;
+ (NSString *)db_AppGoogleAnalyticsKey;
+ (NSString *)db_ParseAppKey;
+ (NSString *)db_ParseClientKey;

+ (NSArray *)db_excludedOrderModules;

// REMOTE
@property (strong, nonatomic) NSString *parseAppKey;
@property (strong, nonatomic) NSString *parseClientKey;

@property (strong, nonatomic) NSString *branchKey;
@property (strong, nonatomic) NSString *gaeKey;

@property (strong, nonatomic) NSString *yandexMetricsKey;

@property (nonatomic) BOOL hasCities;
@property (nonatomic) BOOL hasCompanies;


+ (void)sync:(NSDictionary *)remoteConfig;
+ (NSDictionary *)remoteConfig;
@end



/**
 * Manager for whole application
 */
@interface ApplicationManager : NSObject<ManagerProtocol>

+ (instancetype)sharedInstance;
+ (void)handlePush:(NSDictionary *)push;
+ (void)handleLocalPush:(UILocalNotification *)push;

- (void)initializeVendorFrameworks;
- (void)startApplicationWithOptions:(NSDictionary *)launchOptions;

@end

@interface ApplicationManager(Plist)
+ (void)copyPlistWithName:(NSString *)plistName forceCopy:(BOOL)forceCopy;
+ (void)copyPlistsWithNames:(NSArray *)plistsNames forceCopy:(BOOL)forceCopy;
@end

@interface ApplicationManager(Appearance)
+ (void)applyBrandbookStyle;
+ (UIColor *)applicationColor;
@end

@interface ApplicationManager(Controllers) <DBStartNavControllerDelegate>
- (UIViewController *)rootViewController;

- (UIViewController *)mainViewController;

/**
 * Returns controller for presentation another controller
 * Returns nil if currently presented controller
 */
- (UIViewController *)presentanceContainer;
@end

@interface ApplicationManager(ScreenState)
- (void)moveToStartState:(BOOL)animated;
- (void)moveToMainState:(BOOL)animated;
- (void)moveToScreen:(ApplicationScreen)screen animated:(BOOL)animated;
- (void)moveToScreen:(ApplicationScreen)screen object:(id)object animated:(BOOL)animated;
- (void)moveMenuToStartState:(BOOL)animated;
@end

@interface ApplicationManager(Indexing)
+ (void)continueUserActivity:(NSUserActivity *)activity;
@end

@interface ApplicationManager(Review)
- (void)showReviewViewController:(NSString *)orderId;
@end