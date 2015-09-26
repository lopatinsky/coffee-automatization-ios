//
//  ApplicationManager.m
//  
//
//  Created by Balaban Alexander on 28/07/15.
//
//

#import "ApplicationManager.h"
#import "NetworkManager.h"

#import "OrderCoordinator.h"
#import "DBMenu.h"
#import "Order.h"
#import "Venue.h"

#import "IHPaymentManager.h"
#import "DBCompaniesManager.h"
#import "DBCompanyInfo.h"
#import "DBMenu.h"
#import "DBTabBarController.h"
#import "DBServerAPI.h"
#import "DBShareHelper.h"
#import "DBVersionDependencyManager.h"
#import "DBModulesManager.h"

#import "JRSwizzleMethods.h"
#import <Branch/Branch.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <Parse/Parse.h>
#import <GoogleMaps/GoogleMaps.h>
#import <PayPal-iOS-SDK/PayPalMobile.h>

#import "UIAlertView+BlocksKit.h"

#pragma mark - General

typedef enum : NSUInteger {
    RootStateLaunch,
    RootStateMain,
    RootStateCompanies,
} RootState;

@interface ApplicationManager()

@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic) RootState state;

@end

@implementation ApplicationManager

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static ApplicationManager *instance = nil;
    dispatch_once(&once, ^{ instance = [[self alloc] init]; });
    return instance;
}

- (instancetype)init {
    self = [super init];
    
    self.state = RootStateLaunch;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAlertViewWithInternetError) name:kDBNetworkManagerConnectionFailed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeRoot) name:kDBConcurrentOperationCompaniesLoadSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeRoot) name:kDBConcurrentOperationCompanyInfoLoadSuccess object:nil];
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showAlertViewWithInternetError {
    if (!self.alertView || ![self.alertView isVisible]) {
        self.alertView = [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Ошибка", nil) message:NSLocalizedString(@"Проверьте соединение с интернетом и попробуйте ещё раз", nil)
                                              cancelButtonTitle:NSLocalizedString(@"Повторить", nil) otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:kDBNetworkManagerShouldRetryToRequest object:nil];
                                              }];
    }
}

- (void)changeRoot {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    if (self.state != RootStateMain) {
        [window setRootViewController:[ApplicationManager rootViewController]];
    }
}

#pragma mark - Static

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

#pragma mark - Initialization
@implementation ApplicationManager(Initialization)

+ (void)initializeVendorFrameworks {
    [Parse setApplicationId:[DBCompanyInfo db_companyParseApplicationKey]
                  clientKey:[DBCompanyInfo db_companyParseClientKey]];
    [Fabric with:@[CrashlyticsKit]];
    [GMSServices provideAPIKey:@"AIzaSyCvIyDXuVsBnXDkJuni9va0sCCHuaD0QRo"];
    [JRSwizzleMethods swizzleUIViewDealloc];
    [GANHelper trackClientInfo];
#warning PayPal legacy code
    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction: @"AQ7ORgGNVgz2NNmmwuwPauWbocWczSyYaQ8nOe-eCEGrGD1PNPu6eZOdOovtwSFbkTCKBjVyOPWLnYiL"}];
}

+ (void)startApplicationWithOptions:(NSDictionary *)launchOptions {
    [[Branch getInstance] initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
        if(error){
            NSLog(@"error %@", error);
            [DBServerAPI registerUser:nil];
        } else {
            [DBServerAPI registerUserWithBranchParams:params callback:nil];
        }
    }];
    [DBServerAPI registerUser:nil];
    
    [[DBMenu sharedInstance] updateMenuForVenue:nil remoteMenu:^(BOOL success, NSArray *categories) {
        if(success){
            [DBVersionDependencyManager analyzeUserModifierChoicesFromHistory];
        }
    }];
    [[DBModulesManager sharedInstance] fetchModules:nil];
    [[IHPaymentManager sharedInstance] synchronizePaymentTypes];
    [Order dropOrdersHistoryIfItIsFirstLaunchOfSomeVersions];
    [OrderCoordinator sharedInstance];
    [[OrderCoordinator sharedInstance].promoManager updateInfo];
    [[DBShareHelper sharedInstance] fetchShareSupportInfo];
    [[DBShareHelper sharedInstance] fetchShareInfo:nil];
    
    [[NetworkManager sharedManager] addUniqueOperation:NetworkOperationFetchCompanies];
    [[NetworkManager sharedManager] addPendingUniqueOperation:NetworkOperationFetchVenues];
}

@end

#pragma mark - Style
@implementation ApplicationManager(Style)

+ (void)applyBrandbookStyle {
#warning Farsch legacy code
    if (CGColorEqualToColor([UIColor db_defaultColor].CGColor, [UIColor colorWithRed:0. green:0. blue:0. alpha:1.].CGColor)) {
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
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
//    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
}

@end

@implementation ApplicationManager (Start)
+ (UIViewController *)rootViewController {
    if (([[DBCompaniesManager sharedInstance] companiesLoaded] && [[DBCompaniesManager sharedInstance] companyIsChosen]) || [DBCompanyInfo sharedInstance].deliveryTypes.count > 0) {
        [ApplicationManager sharedInstance].state = RootStateMain;
        return [ViewControllerManager mainViewController];
    } else if ([[DBCompaniesManager sharedInstance] companiesLoaded] && ([[DBCompaniesManager sharedInstance] companies].count > 1)) {
        [ApplicationManager sharedInstance].state = RootStateCompanies;
        return [ViewControllerManager companiesViewControllers];
    } else {
        [ApplicationManager sharedInstance].state = RootStateLaunch;
        return [ViewControllerManager launchViewController];
    }
}
@end

@implementation ApplicationManager (Menu)
+ (Class<MenuListViewControllerProtocol>)rootMenuViewController{
    if([DBMenu sharedInstance].hasNestedCategories){
        return [ViewControllerManager categoriesViewController];
    } else {
        return [ViewControllerManager rootMenuViewController];
    }
}
@end

@implementation ApplicationManager (DemoApp)
+ (UIViewController *)demoLoginViewController{
    Class loginVCClass = NSClassFromString(@"DBDemoLoginViewController");
    
    if(loginVCClass){
        return [[loginVCClass alloc] init];
    } else {
        return nil;
    }
}

@end
