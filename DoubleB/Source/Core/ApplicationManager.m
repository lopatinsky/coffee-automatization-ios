//
//  ApplicationManager.m
//  
//
//  Created by Balaban Alexander on 28/07/15.
//
//

#import "ApplicationManager.h"
#import "AppIndexingManager.h"
#import "NetworkManager.h"

#import "OrderCoordinator.h"
#import "DBMenu.h"
#import "Order.h"
#import "Venue.h"
#import "DBCardsManager.h"
#import "IHSecureStore.h"
#import "UICKeyChainStore.h"

#import "IHPaymentManager.h"
#import "DBCompaniesManager.h"
#import "DBCompanyInfo.h"
#import "DBGeoPushManager.h"
#import "DBMenu.h"
#import "DBServerAPI.h"
#import "DBShareHelper.h"
#import "DBVersionDependencyManager.h"
#import "DBModulesManager.h"
#import "DBGeoPushManager.h"
#import "WatchInteractionManager.h"
#import "CompanyNewsManager.h"

#import "DBAPIClient.h"
#import "DBCommonStartNavController.h"
#import "DBAggregatorStartNavController.h"

#import "DBUnifiedMenuTableViewController.h"
#import "DBUnifiedAppManager.h"

#import "DBOrdersTableViewController.h"
#import "DBOrderViewController.h"
#import "DBVenuesTableViewController.h"
#import "DBVenueViewController.h"
#import "DBMenuViewController.h"
#import "DBCompanySettingsTableViewController.h"

#import "DBMenuViewController.h"
#import "DBPositionViewController.h"

#import "DBSnapshotSDKHelper.h"

#import <Branch/Branch.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <Parse/Parse.h>
#import <GoogleMaps/GoogleMaps.h>
#import <PayPal-iOS-SDK/PayPalMobile.h>

#import "UIAlertView+BlocksKit.h"

#pragma mark - General

typedef NS_ENUM(NSUInteger, RemotePushType) {
    RemotePushOrderType = 1,
    RemotePushTextType,
    RemotePushReviewType,
    RemotePushNewsType,
    RemotePushInvalidType = 999999
};



@implementation ApplicationConfig

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static ApplicationConfig *instance = nil;
    dispatch_once(&once, ^{ instance = [[self alloc] init]; });
    return instance;
}

+ (id)objectFromPropertyListByName:(NSString *)name {
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"CompanyInfo.plist"];
    NSDictionary *companyInfo = [NSDictionary dictionaryWithContentsOfFile:path];
    
    return [companyInfo objectForKey:name];
}

+ (id)objectFromApplicationPreferencesByName:(NSString *)name {
    return [[self objectFromPropertyListByName:@"Preferences"] objectForKey:name];
}

+ (NSString *)db_bundleName {
    NSString *bundleName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    
    return bundleName;
}

+ (ApplicationType)db_appType {
    NSString *typeString = [self objectFromApplicationPreferencesByName:@"ApplicationType"];
    ApplicationType type = ApplicationTypeCommon;
    
    if ([typeString isEqualToString:@"Aggregator"]) {
        type = ApplicationTypeAggregator;
    }
    
    return type;
}

+ (NSString *)db_AppBaseUrl {
    NSString *baseUrl = [self objectFromApplicationPreferencesByName:@"BaseUrl"];
    
    return baseUrl;
}

+ (id)db_AppDefaultColor {
    id colorHex = colorHex = [self objectFromApplicationPreferencesByName:@"CompanyColor"];

    return colorHex;
}

+ (NSString *)db_AppGoogleAnalyticsKey {
    NSString *GAKeyString = [self objectFromApplicationPreferencesByName:@"CompanyGAKey"];
    
    return GAKeyString ?: @"";
}


- (NSString *)parseAppKey {
    NSDictionary *config = [ApplicationConfig remoteConfig];
    
    NSString *key = [[[config getValueForKey:@"keys"] getValueForKey:@"parse"] getValueForKey:@"app_key"];
    return key;
}

- (NSString *)parseClientKey {
    NSDictionary *config = [ApplicationConfig remoteConfig];
    
    NSString *key = [[[config getValueForKey:@"keys"] getValueForKey:@"parse"] getValueForKey:@"client_key"];
    return key;
}

- (NSString *)branchKey {
    NSDictionary *config = [ApplicationConfig remoteConfig];
    
    NSString *key = [[config getValueForKey:@"keys"] getValueForKey:@"branch"];
    return key;
}

- (BOOL)hasCities {
    NSDictionary *config = [ApplicationConfig remoteConfig];
    
    return [[config getValueForKey:@"has_cities"] boolValue];
}

- (BOOL)hasCompanies {
    NSDictionary *config = [ApplicationConfig remoteConfig];
    
    return [[config getValueForKey:@"has_companies"] boolValue];
}

+ (NSDictionary *)remoteConfig {
    NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:@"ApplicationManager_AppConfig"];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

+ (void)sync:(NSDictionary *)remoteConfig {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:remoteConfig];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"ApplicationManager_AppConfig"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end




@interface ApplicationManager()

@property (nonatomic) RootState state;

@end

@implementation ApplicationManager

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static ApplicationManager *instance = nil;
    dispatch_once(&once, ^{ instance = [[self alloc] init]; });
    return instance;
}

+ (void)handlePush:(NSDictionary *)push {
    [GANHelper analyzeEvent:@"push_received" label:[push description] category:@"push_screen"];
    
    NSUInteger pushType = [([push objectForKey:@"type"] ?: @(RemotePushInvalidType)) unsignedIntegerValue];
    switch (pushType) {
        case RemotePushOrderType: {
            NSNotification *notification = [NSNotification notificationWithName:kDBStatusUpdatedNotification
                                                                         object:nil
                                                                       userInfo:push ?: @{}];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            [self showPushAlert:push buttons:nil callback:nil];
            break;
        }
        case RemotePushTextType: {
            if ([([push objectForKey:@"should_popup"] ?: @(0)) boolValue]) {
                UIViewController<PopupNewsViewControllerProtocol> *newsViewController = [ViewControllerManager newsViewController];
                [newsViewController setData:@{@"title": [push getValueForKey:@"title"] ?: @"",
                                              @"text": [push getValueForKey:@"full_text"] ?: @"",
                                              @"image_url": [push getValueForKey:@"image_url"] ?: @""}];
                [[UIViewController currentViewController] presentViewController:newsViewController animated:YES completion:nil];
                break;
            }
        }
        case RemotePushReviewType: {
            [self showPushAlert:push buttons:@[NSLocalizedString(@"Отмена", nil), NSLocalizedString(@"Оценить", nil)] callback:^(NSUInteger buttonIndex) {
                if (buttonIndex == 1) {
                    NSString *orderId = push[@"review"][@"order_id"];
                    [[ApplicationManager sharedInstance] showReviewViewController:orderId];
                }
            }];
            break;
        }
        case RemotePushNewsType: {
            if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
                UIViewController<PopupNewsViewControllerProtocol> *newsViewController = [ViewControllerManager newsViewController];
                [newsViewController setData:@{@"title": [push[@"news_data"] getValueForKey:@"title"] ?: @"",
                                              @"text": [push[@"news_data"] getValueForKey:@"text"] ?: @"",
                                              @"image_url": [push[@"news_data"] getValueForKey:@"image_url"] ?: @""}];
                [[UIViewController currentViewController] presentViewController:newsViewController animated:YES completion:nil];
            }
            break;
        }
        case RemotePushInvalidType:
            break;
        default:
            break;
    }
}

+ (void)handleLocalPush:(UILocalNotification *)push {
    [GANHelper analyzeEvent:@"local_push_received" label:[push description] category:@"push_screen"];
    if ([[[push userInfo] objectForKey:@"type"] isEqualToString:@"geopush"]) {
        [DBGeoPushManager handleLocalPush:push];
    }
}

+ (void)showPushAlert:(NSDictionary *)info buttons:(NSArray *)buttons callback:(void (^)(NSUInteger buttonIndex))callback {
    NSString *title = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
    NSString *message = info[@"aps"][@"alert"];
    if (message.length > 0) {
        if (buttons) {
            [UIAlertView bk_showAlertViewWithTitle:title message:message cancelButtonTitle:nil otherButtonTitles:buttons handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (callback)
                    callback(buttonIndex);
            }];
        } else {
            [UIAlertView bk_showAlertViewWithTitle:title message:message cancelButtonTitle:@"OK" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (callback)
                    callback(buttonIndex);
            }];
        }
    }
    
}

- (instancetype)init {
    self = [super init];
    
    self.state = RootStateStart;
    
    return self;
}


#pragma mark - Frameworks initialization
- (void)initializeVendorFrameworks {
    if ([ApplicationConfig sharedInstance].parseAppKey && [ApplicationConfig sharedInstance].parseClientKey) {
        [Parse setApplicationId:[ApplicationConfig sharedInstance].parseAppKey
                      clientKey:[ApplicationConfig sharedInstance].parseClientKey];
    }
    
    [Fabric with:@[CrashlyticsKit]];
    [GMSServices provideAPIKey:@"AIzaSyCvIyDXuVsBnXDkJuni9va0sCCHuaD0QRo"];
    
    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction: @"AQ7ORgGNVgz2NNmmwuwPauWbocWczSyYaQ8nOe-eCEGrGD1PNPu6eZOdOovtwSFbkTCKBjVyOPWLnYiL"}];
}

- (void)startApplicationWithOptions:(NSDictionary *)launchOptions {
    if ([ApplicationConfig remoteConfig] != nil) {
        [self initializeVendorFrameworks];
    }
    
    [DBVersionDependencyManager performAll];
    [GANHelper trackClientInfo];
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        [GANHelper analyzeEvent:@"swipe" label:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] category:@"Notification"];
        [ApplicationManager handlePush:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
    }
    
    [[NetworkManager sharedManager] addPendingUniqueOperation:NetworkOperationRegister withUserInfo:@{@"launch_options": launchOptions ?: @{}}];
    
    [IHPaymentManager sharedInstance];
    [DBShareHelper sharedInstance];
    [OrderCoordinator sharedInstance];
    
#ifdef DEBUG
    if ([[NSProcessInfo processInfo].environment objectForKey:@"UITest"]) {
        [DBSnapshotSDKHelper sharedInstance];
    }
#endif
    
}

- (void)awakeFromNotification:(NSDictionary *)userInfo {
    UIViewController<PopupNewsViewControllerProtocol> *newsViewController = [ViewControllerManager newsViewController];
    [newsViewController setData:@{@"text": [userInfo[@"aps"] getValueForKey:@"alert"] ?: @"", @"image_url": @""}];
    [[UIViewController currentViewController] presentViewController:newsViewController animated:YES completion:nil];
}

- (void)recieveNotification:(NSDictionary *)userInfo {
    if([UIApplication sharedApplication].applicationState != 0){
        [self awakeFromNotification:userInfo];
    }
}

#pragma mark - API Notification handlers
- (void)companiesLoadedSuccess {
    if([DBCompaniesManager sharedInstance].hasCompanies && ![DBCompaniesManager sharedInstance].companyIsChosen){
        [self changeRoot];
    } else {
        [[NetworkManager sharedManager] addUniqueOperation:NetworkOperationFetchCompanyInfo];
    }
}

- (void)changeRoot {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [window setRootViewController:[self rootViewController]];
}

#pragma mark - ManagerProtocol

- (void)flushCache {
    [[OrderCoordinator sharedInstance] flushCache];
    [[DBCompanyInfo sharedInstance] flushCache];
    [[DBMenu sharedInstance] clearMenu];
    [Venue dropAllVenues];
    [Order dropAllOrders];
}

- (void)flushStoredCache {
    [[OrderCoordinator sharedInstance] flushStoredCache];
    [[DBCompanyInfo sharedInstance] flushStoredCache];
    [[DBMenu sharedInstance] clearMenu];
    [Venue dropAllVenues];
    [Order dropAllOrders];
}

@end

#pragma mark - Plist
@implementation ApplicationManager(Plist)

+ (void)copyPlistWithName:(NSString *)plistName forceCopy:(BOOL)forceCopy {
    NSString *buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    NSString *storedBuildNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"STORED_BUILD_NUMBER"] ?: @"0";
    if (forceCopy || [buildNumber compare:storedBuildNumber] == NSOrderedDescending) {
        [ApplicationManager copyPlistContent:[ApplicationManager getPlistContent:@"CompanyInfo"] withName:@"CompanyInfo"];
        [[NSUserDefaults standardUserDefaults] setObject:buildNumber forKey:@"STORED_BUILD_NUMBER"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (void)copyPlistsWithNames:(NSArray *)plistsNames forceCopy:(BOOL)forceCopy {
    [plistsNames enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        [ApplicationManager copyPlistWithName:obj forceCopy:forceCopy];
    }];
}

+ (void)copyPlistContent:(NSDictionary *)content withName:(NSString *)name {
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths firstObject];
    NSString *plistPath = [directory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", name]];
    
    if (![fileManager fileExistsAtPath:plistPath]) {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:name ofType:@"plist"];
        [fileManager copyItemAtPath:bundle toPath:plistPath error:&error];
    }
    [content writeToFile:plistPath atomically:YES];
}

+ (NSMutableDictionary *)getPlistContent:(NSString *)name {
    NSString *pathToPlist = [[NSBundle mainBundle] pathForResource:name ofType:@".plist"];
    NSDictionary *plistDict = [NSDictionary dictionaryWithContentsOfFile:pathToPlist];
    return [[NSMutableDictionary alloc] initWithDictionary:plistDict];
}

@end

#pragma mark - Style
@implementation ApplicationManager(Style)

+ (void)applyBrandbookStyle {
    if ([[ApplicationConfig db_bundleName].lowercaseString isEqualToString:@"redcup"] && [UIDevice systemVersionGreaterOrEqualsThan:@"8.0"]) {
        [UINavigationBar appearance].translucent = NO;
    }
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor db_defaultColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName: [UIColor whiteColor],
                                                           NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.f]
                                                           }];
}

@end


@implementation ApplicationManager (Indexing)

+ (void)continueUserActivity:(NSUserActivity *)activity {
    if ([activity.activityType hasPrefix:@"com.empatika."]) {
        [[WatchInteractionManager sharedInstance] continueUserActivity:activity];
    } else {
        [[AppIndexingManager sharedManager] continueUserActivity:activity];
    }
}

@end

@implementation ApplicationManager (Start)

- (UIViewController *)rootViewController {
    if (self.state == RootStateStart) {
        switch ([ApplicationConfig db_appType]) {
            case ApplicationTypeCommon: {
                DBStartNavController *startNavVC = [DBClassLoader loadStartNavigationController];
                startNavVC.navDelegate = self;
                return startNavVC;
            }
                break;
            case ApplicationTypeAggregator:
                return [[DBAggregatorStartNavController alloc] initWithDelegate:self];
                break;
                
            default:
                break;
        }
    }
    
    return [self mainViewController];
}

- (void)db_startNavVCNeedsMoveToMain:(UIViewController *)controller {
    self.state = RootStateMain;
    
    [[DBCompanyInfo sharedInstance] fetchDependentInfo];
    [self changeRoot];
}

@end

@implementation ApplicationManager (Controllers)

- (UIViewController *)mainViewController {
    if ([[ApplicationConfig db_bundleName].lowercaseString isEqualToString:@"coffeetogo"]) {
        [[DBUnifiedAppManager sharedInstance] fetchMenu:nil];
        [[DBUnifiedAppManager sharedInstance] fetchVenues:nil];
        
        DBUnifiedMenuTableViewController *menuVC = [DBUnifiedMenuTableViewController new];
        menuVC.type = UnifiedVenue;
        return [[UINavigationController alloc] initWithRootViewController:menuVC];
    } else {
        return [[UINavigationController alloc] initWithRootViewController:[DBMenuViewController new]];
    }
}

@end

@implementation ApplicationManager (ScreenState)

- (void)moveToStartState:(BOOL)animated {
    self.state = RootStateStart;
    [self changeRoot];
}

- (void)moveToScreen:(ApplicationScreen)screen animated:(BOOL)animated {
    [self moveToScreen:screen object:nil animated:animated];
}

- (void)moveToScreen:(ApplicationScreen)screen object:(id)object animated:(BOOL)animated {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    UIViewController *rootVC = window.rootViewController;
    
    switch (screen) {
        case ApplicationScreenRoot:{
            if ([rootVC isKindOfClass:[UINavigationController class]]){
                [((UINavigationController*)rootVC) setViewControllers:@[((UINavigationController*)rootVC).viewControllers.firstObject] animated:animated];
            }
        } break;
            
        case ApplicationScreenOrder: {
            if ([rootVC isKindOfClass:[UINavigationController class]]){
                UIViewController *newOrderVC = [DBClassLoader loadNewOrderVC];
                [((UINavigationController*)rootVC) setViewControllers:@[((UINavigationController*)rootVC).viewControllers.firstObject, newOrderVC] animated:animated];
            }
        } break;
            
        case ApplicationScreenHistory:{
            if ([rootVC isKindOfClass:[UINavigationController class]]){
                DBCompanySettingsTableViewController *settingsVC = (DBCompanySettingsTableViewController *)[DBClassLoader loadSettingsViewController];
                DBOrdersTableViewController *ordersVC = [DBOrdersTableViewController new];
                [((UINavigationController*)rootVC) setViewControllers:@[((UINavigationController*)rootVC).viewControllers.firstObject, settingsVC, ordersVC] animated:animated];
            }
        }break;
            
        case ApplicationScreenHistoryOrder:{
            if ([rootVC isKindOfClass:[UINavigationController class]]){
                DBCompanySettingsTableViewController *settingsVC = (DBCompanySettingsTableViewController *)[DBClassLoader loadSettingsViewController];
                DBOrdersTableViewController *ordersVC = [DBOrdersTableViewController new];
                DBOrderViewController *orderVC = [DBOrderViewController new];
                if ([object isKindOfClass:[Order class]]) {
                    orderVC.order = object;
                } else if ([object isKindOfClass:[NSString class]]) {
                    orderVC.order = [Order orderById:object];
                }
                [((UINavigationController*)rootVC) setViewControllers:@[((UINavigationController*)rootVC).viewControllers.firstObject, settingsVC, ordersVC, orderVC] animated:animated];
            }
        }break;
        
        case ApplicationScreenVenue: {
            if ([rootVC isKindOfClass:[UINavigationController class]]) {
                UIViewController *newOrderVC = [DBClassLoader loadNewOrderVC];
                UIViewController *venuesVC = [DBVenuesTableViewController new];
                DBVenueViewController *venueVC = [DBVenueViewController new];
                if ([object isKindOfClass:[Venue class]]) {
                    venueVC.venue = object;
                } else if ([object isKindOfClass:[NSString class]]) {
                    venueVC.venue = [Venue venueById:object];
                }
                [((UINavigationController*)rootVC) setViewControllers:@[((UINavigationController*)rootVC).viewControllers.firstObject, newOrderVC, venuesVC, venueVC] animated:animated];
            }
            break;
        }
        case ApplicationScreenMenu: {
            if ([rootVC isKindOfClass:[UINavigationController class]]) {
                [((UINavigationController*)rootVC) setViewControllers:@[[DBMenuViewController new]] animated:animated];
            }
            break;
        }
        default:
            break;
    }
}

- (void)moveMenuToStartState:(BOOL)animated {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    UIViewController *rootVC = window.rootViewController;
    
    if ([rootVC isKindOfClass:[UINavigationController class]]){
        UINavigationController *rootNavVC = (UINavigationController *)rootVC;
        NSMutableArray *controllers = [[NSMutableArray alloc] initWithArray:rootNavVC.viewControllers];
        
        while (controllers.count > 1 && ([controllers[1] isKindOfClass:[DBMenuViewController class]] || [controllers[1] isKindOfClass:[DBPositionViewController class]])) {
            [controllers removeObjectAtIndex:1];
        }
        
        [rootNavVC setViewControllers:controllers animated:animated];
    }
}

@end

@implementation ApplicationManager (Review)
- (void)showReviewViewController:(NSString *)orderId {
    UIViewController<ReviewViewControllerProtocol> *reviewViewController = [ViewControllerManager reviewViewController];
    [reviewViewController setOrderId:orderId];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:reviewViewController];
    [[UIViewController currentViewController] presentViewController:navigationController animated:YES completion:nil];
}
@end
