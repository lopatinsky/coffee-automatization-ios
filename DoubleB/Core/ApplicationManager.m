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
#import "DBCardsManager.h"
#import "IHSecureStore.h"
#import "UICKeyChainStore.h"

#import "IHPaymentManager.h"
#import "DBCompaniesManager.h"
#import "DBCompanyInfo.h"
#import "DBMenu.h"
#import "DBServerAPI.h"
#import "DBShareHelper.h"
#import "DBVersionDependencyManager.h"
#import "DBModulesManager.h"
#import "DBGeoPushManager.h"

#import "DBSettingsTableViewController.h"
#import "DBOrdersTableViewController.h"
#import "DBOrderViewController.h"

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
    [GANHelper analyzeEvent:@"push_received" label:[push description] category:@"push_screen"];
    if ([push objectForKey:@"type"]) {
        if ([[push objectForKey:@"type"] integerValue] == 3) {
            [self showPushAlert:push buttons:@[NSLocalizedString(@"Отмена", nil), NSLocalizedString(@"Оценить", nil)] callback:^(NSUInteger buttonIndex) {
                if (buttonIndex == 1) {
                    NSString *orderId = push[@"review"][@"order_id"];
                    [[ApplicationManager sharedInstance] showReviewViewController:orderId];
                }
            }];
        }
    } else if ([push objectForKey:@"aps"]) {
        [self showPushAlert:push buttons:nil callback:nil];
        
        NSNotification *notification = [NSNotification notificationWithName:kDBStatusUpdatedNotification
                                                                     object:nil
                                                                   userInfo:push ?: @{}];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
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
    [[DBModulesManager sharedInstance] fetchModules:nil];
    [[IHPaymentManager sharedInstance] synchronizePaymentTypes];
    [[OrderCoordinator sharedInstance].promoManager updateInfo];
    [[DBShareHelper sharedInstance] fetchShareSupportInfo];
    [[DBShareHelper sharedInstance] fetchShareInfo:nil];
    
    [[NetworkManager sharedManager] addPendingUniqueOperation:NetworkOperationFetchVenues];
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
        return [self mainViewController];
    }
    if ([self currentState] == RootStateCompanies) {
        return[[UINavigationController alloc] initWithRootViewController:[ViewControllerManager companiesViewController]];
    }
    if ([self currentState] == RootStateLaunch) {
        return [ViewControllerManager launchViewController];
    }
    
    return [self mainViewController];
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
                orderVC.order = object;
                [((UINavigationController*)rootVC) setViewControllers:@[((UINavigationController*)rootVC).viewControllers.firstObject, settingsVC, ordersVC, orderVC] animated:animated];
            }
        }break;
            
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
