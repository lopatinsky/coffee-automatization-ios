//
//  ApplicationManager.m
//  
//
//  Created by Balaban Alexander on 28/07/15.
//
//

#import "ApplicationManager.h"
#import "OrderCoordinator.h"
#import "ViewControllerManager.h"

#import "Order.h"
#import "Venue.h"

#import "DBCompanyInfo.h"
#import "DBMenu.h"
#import "DBTabBarController.h"
#import "DBServerAPI.h"

#import "JRSwizzleMethods.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <Parse/Parse.h>
#import <GoogleMaps/GoogleMaps.h>
#import <PayPal-iOS-SDK/PayPalMobile.h>

#pragma mark - General
@implementation ApplicationManager

+ (nonnull UIViewController *)rootViewController {
    if (![DBCompanyInfo sharedInstance].deliveryTypes) {
        return [ViewControllerManager launchViewController];
    } else {
        if ([DBCompanyInfo db_companyChoiceEnabled] && [[DBCompanyInfo sharedInstance].currentCompanyName isEqualToString:@""]) {
//            return [DBCompaniesViewController new];
        }
        
        // Login VC for demoApp
        if  ([[DBCompanyInfo sharedInstance].bundleName.lowercaseString isEqualToString:@"rubeacondemo"]){
            return [self demoLoginViewController];
        }
        
        return [ViewControllerManager mainViewController];
    }
}

+ (void)copyPlistWithName:(nonnull NSString *)plistName forceCopy:(BOOL)forceCopy {
    NSString *buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    NSString *storedBuildNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"STORED_BUILD_NUMBER"] ?: @"0";
    if (forceCopy || [buildNumber compare:storedBuildNumber] == NSOrderedDescending) {
        [ApplicationManager copyPlistContent:[ApplicationManager getPlistContent:@"CompanyInfo"] withName:@"CompanyInfo"];
        [[NSUserDefaults standardUserDefaults] setObject:buildNumber forKey:@"STORED_BUILD_NUMBER"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (void)copyPlistsWithNames:(nonnull NSArray *)plistsNames forceCopy:(BOOL)forceCopy {
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

+ (void)initializeOrderFramework {
    [DBServerAPI registerUser:nil];
    
    [Venue fetchAllVenuesWithCompletionHandler:^(NSArray *venues) {
        // TODO: Save database context
    }];
    [[DBMenu sharedInstance] updateMenuForVenue:nil remoteMenu:nil];
    [Order dropOrdersHistoryIfItIsFirstLaunchOfSomeVersions];
    [[OrderCoordinator sharedInstance].promoManager updateInfo];
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
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
}

@end

@implementation ApplicationManager (Menu)
+ (nonnull Class<MenuListViewControllerProtocol>)rootMenuViewController{
    if([DBMenu sharedInstance].hasNestedCategories){
        return [ViewControllerManager categoriesViewController];
    } else {
        return [ViewControllerManager rootMenuViewController];
    }
}
@end

@implementation ApplicationManager (DemoApp)
+ (nonnull UIViewController *)demoLoginViewController{
    Class loginVCClass = NSClassFromString(@"DBDemoLoginViewController");
    
    if(loginVCClass){
        return [[loginVCClass alloc] init];
    } else {
        return nil;
    }
}

@end
