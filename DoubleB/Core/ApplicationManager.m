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

#import "JRSwizzleMethods.h"
#import <Branch/Branch.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <Parse/Parse.h>
#import <GoogleMaps/GoogleMaps.h>
#import <PayPal-iOS-SDK/PayPalMobile.h>

#import "UIAlertView+BlocksKit.h"

#pragma mark - General

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

+ (void)handlePush:(NSDictionary *)push {
    if ([push objectForKey:@"type"]) {
        if ([[push objectForKey:@"type"] integerValue] == 3) {
            NSString *orderId = push[@"review"][@"order_id"];
            [[ApplicationManager sharedInstance] showReviewViewController:orderId];
        }
    }
}

- (instancetype)init {
    self = [super init];
    
    self.state = [self currentState];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAlertViewWithInternetError) name:kDBNetworkManagerConnectionFailed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(companiesLoadedSuccess) name:kDBConcurrentOperationCompaniesLoadSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(companyInfoLoadedSuccess) name:kDBConcurrentOperationCompanyInfoLoadSuccess object:nil];
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Frameworks initialization
- (void)initializeVendorFrameworks {
    [Parse setApplicationId:[DBCompanyInfo db_companyParseApplicationKey]
                  clientKey:[DBCompanyInfo db_companyParseClientKey]];
    [Fabric with:@[CrashlyticsKit]];
    [GMSServices provideAPIKey:@"AIzaSyCvIyDXuVsBnXDkJuni9va0sCCHuaD0QRo"];
    [JRSwizzleMethods swizzleUIViewDealloc];
    [GANHelper trackClientInfo];
#warning PayPal legacy code
    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction: @"AQ7ORgGNVgz2NNmmwuwPauWbocWczSyYaQ8nOe-eCEGrGD1PNPu6eZOdOovtwSFbkTCKBjVyOPWLnYiL"}];
}

- (void)startApplicationWithOptions:(NSDictionary *)launchOptions {
    [DBVersionDependencyManager performAll];
    
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
    
    // Fetch all companies
    [[NetworkManager sharedManager] addPendingUniqueOperation:NetworkOperationFetchCompanies];
    
    // Init update all necessary info if company has chosen
    if ([self currentState] == RootStateMain) {
        [[NetworkManager sharedManager] addUniqueOperation:NetworkOperationFetchCompanyInfo];
        [self fetchCompanyDependentInfo];
    }
}

- (void)fetchCompanyDependentInfo {
    // Update menu
    [[DBMenu sharedInstance] updateMenuForVenue:nil remoteMenu:^(BOOL success, NSArray *categories) {
        if(success){
            // Analyse user history to fetch selected modifiers
            [DBVersionDependencyManager analyzeUserModifierChoicesFromHistory];
        }
    }];
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

- (void)companyInfoLoadedSuccess {
    if (self.state != [self currentState]){
        [self fetchCompanyDependentInfo];
    }
    
    [self changeRoot];
}

- (void)showAlertViewWithInternetError {
    BOOL show = YES;
    show = show && ![self.alertView isVisible];
    show = show && ([ApplicationManager sharedInstance].state == RootStateLaunch);
    if (show) {
        if(!self.alertView){
            self.alertView = [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Ошибка", nil) message:NSLocalizedString(@"Проверьте соединение с интернетом и попробуйте ещё раз", nil)
                                                  cancelButtonTitle:NSLocalizedString(@"Повторить", nil) otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                          [[NSNotificationCenter defaultCenter] postNotificationName:kDBNetworkManagerShouldRetryToRequest object:nil];
                                                      });
                                                  }];
        }
        
        [self.alertView show];
    }
}

- (void)changeRoot {
    if (self.state != [self currentState]) {
        self.state = [self currentState];
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        [window setRootViewController:[self rootViewController]];
    }
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
        if ([[DBCompanyInfo  sharedInstance].bundleName.lowercaseString isEqualToString:@"redcup"]) {
            [UINavigationBar appearance].translucent = NO;
        }
        
        [[UINavigationBar appearance] setBarTintColor:[UIColor db_defaultColor]];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                               NSForegroundColorAttributeName: [UIColor whiteColor],
                                                               NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.f]
                                                               }];
    }
}

@end

@implementation ApplicationManager (Start)

- (RootState)currentState {
    if ([DBCompanyInfo sharedInstance].infoLoaded) {
        return RootStateMain;
    }
    
    if ([[DBCompaniesManager sharedInstance] companiesLoaded] && [DBCompaniesManager sharedInstance].hasCompanies && ![DBCompaniesManager sharedInstance].companyIsChosen) {
        return RootStateCompanies;
    }
    
    return RootStateLaunch;
}

- (UIViewController *)rootViewController {
    if ([self currentState] == RootStateMain) {
        return [ViewControllerManager mainViewController];
    }
    if ([self currentState] == RootStateCompanies) {
        return[[UINavigationController alloc] initWithRootViewController:[ViewControllerManager companiesViewControllers]];
    }
    if ([self currentState] == RootStateLaunch) {
        return [ViewControllerManager launchViewController];
    }
    
    return [ViewControllerManager mainViewController];
}
@end

@implementation ApplicationManager (Menu)
- (Class<MenuListViewControllerProtocol>)rootMenuViewController{
    if([DBMenu sharedInstance].hasNestedCategories){
        return [ViewControllerManager categoriesViewController];
    } else {
        return [ViewControllerManager rootMenuViewController];
    }
}
@end

@implementation ApplicationManager (DemoApp)
- (UIViewController *)demoLoginViewController{
    Class loginVCClass = NSClassFromString(@"DBDemoLoginViewController");
    
    if(loginVCClass){
        return [[loginVCClass alloc] init];
    } else {
        return nil;
    }
}
@end

@implementation ApplicationManager (Review)
- (void)showReviewViewController:(NSString *)orderId {
    UIViewController<ReviewViewControllerProtocol> *reviewViewController = [ViewControllerManager reviewViewController];
    [reviewViewController setOrderId:orderId];
    [[UIViewController currentViewController] presentViewController:reviewViewController animated:YES completion:^{
        
    }];
}
@end
