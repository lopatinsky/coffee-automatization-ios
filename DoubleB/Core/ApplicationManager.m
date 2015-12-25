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

#import "IHPaymentManager.h"
#import "DBCompaniesManager.h"
#import "DBCompanyInfo.h"
#import "DBMenu.h"
#import "DBServerAPI.h"
#import "DBShareHelper.h"
#import "DBVersionDependencyManager.h"
#import "DBModulesManager.h"
#import "DBGeoPushManager.h"
#import "WatchInteractionManager.h"

#import "DBStartNavController.h"
#import "DBCommonStartNavController.h"
#import "DBProxyStartNavController.h"
#import "DBDemoStartNavController.h"
#import "DBAggregatorStartNavController.h"

#import "DBOrdersTableViewController.h"
#import "DBOrderViewController.h"
#import "DBVenuesTableViewController.h"
#import "DBVenueViewController.h"

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
            if ([UIApplication sharedApplication].applicationState != 0) {
                UIViewController<PopupNewsViewControllerProtocol> *newsViewController = [ViewControllerManager newsViewController];
                [newsViewController setData:@{@"title": [push getValueForKey:@"title"],
                                              @"text": [push getValueForKey:@"full_text"],
                                              @"image_url": [push getValueForKey:@"image_url"] ?: @""}];
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

- (ApplicationType)applicationType {
    NSString *typeString = [DBCompanyInfo objectFromApplicationPreferencesByName:@"ApplicationType"];
    ApplicationType type = ApplicationTypeCommon;
    
    if ([typeString isEqualToString:@"Proxy"]) {
        type = ApplicationTypeProxy;
    }
    
    if ([typeString isEqualToString:@"Aggregator"]) {
        type = ApplicationTypeAggregator;
    }
    
    if ([typeString isEqualToString:@"Demo"]) {
        type = ApplicationTypeDemo;
    }
    
    return type;
}


#pragma mark - Frameworks initialization
- (void)initializeVendorFrameworks {
    [Parse setApplicationId:[DBCompanyInfo db_companyParseApplicationKey]
                  clientKey:[DBCompanyInfo db_companyParseClientKey]];
    [Fabric with:@[CrashlyticsKit]];
    [GMSServices provideAPIKey:@"AIzaSyCvIyDXuVsBnXDkJuni9va0sCCHuaD0QRo"];
#warning PayPal legacy code
    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction: @"AQ7ORgGNVgz2NNmmwuwPauWbocWczSyYaQ8nOe-eCEGrGD1PNPu6eZOdOovtwSFbkTCKBjVyOPWLnYiL"}];
    
    [GANHelper trackClientInfo];
}

- (void)startApplicationWithOptions:(NSDictionary *)launchOptions {
    [DBVersionDependencyManager performAll];
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        [GANHelper analyzeEvent:@"swipe" label:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] category:@"Notification"];
        [ApplicationManager handlePush:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
    }
    
    // Check Branch and register user
    [[Branch getInstance] initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
        if(error){
            NSLog(@"error %@", error);
            [DBServerAPI registerUser:nil];
        } else {
            [DBServerAPI registerUserWithBranchParams:params callback:nil];
        }
    }];
    
    [IHPaymentManager sharedInstance];
    [DBShareHelper sharedInstance];
    [OrderCoordinator sharedInstance];
}

- (void)fetchCompanyDependentInfo {
    // Update menu
    [[DBMenu sharedInstance] updateMenuForVenue:nil remoteMenu:^(BOOL success, NSArray *categories) {
        if(success){
            // Analyse user history to fetch selected modifiers
            [DBVersionDependencyManager analyzeUserModifierChoicesFromHistory];
        }
    }];
    [[DBModulesManager sharedInstance] fetchModules:nil];
    [[IHPaymentManager sharedInstance] synchronizePaymentTypes];
    [[OrderCoordinator sharedInstance].promoManager updateInfo];
    [[DBShareHelper sharedInstance] fetchShareSupportInfo];
    [[DBShareHelper sharedInstance] fetchShareInfo:nil];
    
    [[NetworkManager sharedManager] addPendingUniqueOperation:NetworkOperationFetchVenues];
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
#warning Farsch legacy code
    if ([[DBCompanyInfo  sharedInstance].bundleName.lowercaseString isEqualToString:@"farsh"]) {
        [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
        [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                               NSForegroundColorAttributeName: [UIColor blackColor],
                                                               NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.f]
                                                               }];
    } else {
        [[UINavigationBar appearance] setBarTintColor:[UIColor db_defaultColor]];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                               NSForegroundColorAttributeName: [UIColor whiteColor],
                                                               NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.f]
                                                               }];
    }
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
        switch (self.applicationType) {
            case ApplicationTypeCommon:
                return [[DBCommonStartNavController alloc] initWithDelegate:self];
                break;
            case ApplicationTypeProxy:
                return [[DBProxyStartNavController alloc] initWithDelegate:self];
                break;
            case ApplicationTypeDemo:
                return [[DBDemoStartNavController alloc] initWithDelegate:self];
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
    
    [self fetchCompanyDependentInfo];
    [self changeRoot];
}

@end

@implementation ApplicationManager (Controllers)

- (UIViewController *)mainViewController {
    return [[UINavigationController alloc] initWithRootViewController:[[self mainMenuViewController] createViewController]];
}


- (Class<MenuListViewControllerProtocol>)mainMenuViewController{
    if([DBMenu sharedInstance].hasNestedCategories){
        return [ViewControllerManager categoriesViewController];
    } else {
        return [ViewControllerManager rootMenuViewController];
    }
}
@end

@implementation ApplicationManager (ScreenState)

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
                UIViewController *newOrderVC = [DBClassLoader loadNewOrderViewController];
                [((UINavigationController*)rootVC) setViewControllers:@[((UINavigationController*)rootVC).viewControllers.firstObject, newOrderVC] animated:animated];
            }
        } break;
            
        case ApplicationScreenHistory:{
            if ([rootVC isKindOfClass:[UINavigationController class]]){
                DBSettingsTableViewController *settingsVC = [DBClassLoader loadSettingsViewController];
                DBOrdersTableViewController *ordersVC = [DBOrdersTableViewController new];
                [((UINavigationController*)rootVC) setViewControllers:@[((UINavigationController*)rootVC).viewControllers.firstObject, settingsVC, ordersVC] animated:animated];
            }
        }break;
            
        case ApplicationScreenHistoryOrder:{
            if ([rootVC isKindOfClass:[UINavigationController class]]){
                DBSettingsTableViewController *settingsVC = [DBClassLoader loadSettingsViewController];
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
                UIViewController *newOrderVC = [DBClassLoader loadNewOrderViewController];
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
            
        default:
            break;
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
