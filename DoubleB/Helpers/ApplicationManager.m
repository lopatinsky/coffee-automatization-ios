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
        return [ViewControllerManager mainViewController];
    }
}

+ (void)copyPlists {
    NSArray *plists = @[@"CompanyInfo", @"ViewControllers", @"Views"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths firstObject];
    for (NSString *plistName in plists) {
        [ApplicationManager copyPlistWithName:plistName withDocumentDirectory:documentDirectory];
    }
}

+ (void)copyPlistWithName:(NSString * __nonnull)plistName withDocumentDirectory:(NSString * __nonnull)directory {
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [directory stringByAppendingPathComponent:[plistName stringByAppendingString:@".plist"]];
    if (![fileManager fileExistsAtPath:path]) {
        NSString *pathToPlist = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
        if (pathToPlist) {
            [fileManager copyItemAtPath:pathToPlist toPath:path error:&error];
        }
    }
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
    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction: @"AQ7ORgGNVgz2NNmmwuwPauWbocWczSyYaQ8nOe"}];
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
+ (Class<MenuListViewControllerProtocol> __nonnull)rootMenuViewController{
    if([DBMenu sharedInstance].hasNestedCategories){
        return [ViewControllerManager categoriesViewController];
    } else {
        return [ViewControllerManager rootMenuViewController];
    }
}

@end
