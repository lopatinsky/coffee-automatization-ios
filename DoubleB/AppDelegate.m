//
//  AppDelegate.m
//  DoubleB
//
//  Created by Sergey Pronin on 6/21/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "AppDelegate.h"
#import "Venue.h"
#import "Order.h"
#import "DBServerAPI.h"
#import "DBTabBarController.h"
#import "JRSwizzleMethods.h"
#import "DBCompanyInfo.h"
#import "DBPromoManager.h"
#import "DBMenu.h"
#import "IHSecureStore.h"

#import "DBLaunchEmulationViewController.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <Parse/Parse.h>
#import <GoogleMaps/GoogleMaps.h>
//#import <PayPal-iOS-SDK/PayPalMobile.h>

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self copyPlist];
    
//==================== Frameworks initialization ====================
    [Parse setApplicationId:[DBCompanyInfo db_companyParseApplicationKey]
                  clientKey:[DBCompanyInfo db_companyParseClientKey]];
    
    [Fabric with:@[CrashlyticsKit]];
    
//    [GMSServices provideAPIKey:@"AIzaSyAbXdWCR4ygPVIpQCNq6zW5liZ_22biryg"];
    [GMSServices provideAPIKey:@"AIzaSyCvIyDXuVsBnXDkJuni9va0sCCHuaD0QRo"];
    
//    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentSandbox:@"Aedvczd_fDZnfkriC94V1gr46UqlpqnAcO7VDIL9nRjK50N_chA15XyeE96j4hORw5nz1Fstxi6Mzmin"}];
//==================== Framework initialization =====================
    
    
//================ significant preloadings/initializations =================
    [DBServerAPI registerUser:nil];
    
    [Venue fetchAllVenuesWithCompletionHandler:^(NSArray *venues) {
        [self saveContext];
    }];
    
    [[DBMenu sharedInstance] updateMenuForVenue:nil remoteMenu:nil];
    
    [Order dropOrdersHistoryIfItIsFirstLaunchOfSomeVersions];
    
    [JRSwizzleMethods swizzleUIViewDealloc];
    //[DBShareHelper sharedInstance];
    [[DBPromoManager sharedManager] updateInfo];
    
    [GANHelper trackClientInfo];
//================ significant preloadings/initializations =================

    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        [GANHelper analyzeEvent:@"swipe" label:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] category:@"Notification"];
    }
    
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        [[DBTabBarController sharedInstance] awakeFromRemoteNotification];
    }
    
    //styling
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor db_defaultColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
        NSForegroundColorAttributeName: [UIColor whiteColor],
        NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.f]
    }];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    if ([DBCompanyInfo db_companyChoiceEnabled] && [[DBCompanyInfo sharedInstance].currentCompanyName isEqualToString:@""]) {
        self.window.rootViewController = [[DBCompaniesViewController alloc] initWithNibName:@"DBCompaniesViewController" bundle:[NSBundle mainBundle]];
    } else {
        if (![DBCompanyInfo sharedInstance].deliveryTypes) {
            self.window.rootViewController = [DBLaunchEmulationViewController new];
        } else {
            self.window.rootViewController = [DBTabBarController sharedInstance];
        }
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //[DBMastercardPromo checkLocalNotificationExpirationDate];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSString *clientId = [IHSecureStore sharedInstance].clientId;
    if(clientId){
        [GANHelper analyzeEvent:@"app_started" label:clientId category:@"Start_application"];
    } else {
        [GANHelper analyzeEvent:@"app_started" category:@"Start_application"];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

    [self saveContext];

}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
//    [GANHelper analyzeEvent:@"push" label:@"success" category:@"Notification"];

    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
    
    NSNumber *lastOrderId = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastOrderId"];
    if (lastOrderId) {
        [PFPush subscribeToChannelInBackground:[NSString stringWithFormat:[DBCompanyInfo sharedInstance].orderPushChannel, lastOrderId]];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"%s -> %@", __PRETTY_FUNCTION__, error);
}

//- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
//
//}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];

    NSNotification *notification = [NSNotification notificationWithName:kDBStatusUpdatedNotification
                                                                 object:nil
                                                               userInfo:userInfo ?: @{}];

    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    NSLog(@"%@", notification);
    //[DBMastercardPromo clearAllLocalNotifications];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DoubleB" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"DoubleB.sqlite"];
    
    NSError *error = nil;
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
                                                           error:&error]) {
        
        static BOOL onceToken;
        if(!onceToken){
            [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
            onceToken = YES;
            
            _persistentStoreCoordinator = nil;
            return [self persistentStoreCoordinator];
        } else {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    return _persistentStoreCoordinator;
}

-(BOOL)application:(UIApplication *)application shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier {
    if (extensionPointIdentifier == UIApplicationKeyboardExtensionPointIdentifier) {
        return NO;
    }
    return YES;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)copyPlist{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths firstObject];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"CompanyInfo.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if(![fileManager fileExistsAtPath:path]){
        NSString *pathToCompanyInfo = [[NSBundle mainBundle] pathForResource:@"CompanyInfo" ofType:@"plist"];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:pathToCompanyInfo];
        [fileManager copyItemAtPath:pathToCompanyInfo toPath:path error:&error];
    }
}

@end