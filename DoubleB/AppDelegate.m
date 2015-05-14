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
#import "DBPreviewViewController.h"
#import "DBMastercardPromo.h"
#import "DBMenu.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <Parse/Parse.h>
#import <GoogleMaps/GoogleMaps.h>

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //==================== Frameworks initialization ====================
    [Parse setApplicationId:@"sSS9VgN9K2sU3ycxzwQlwrBZPFlEe7OvSNZQDjQe"
                  clientKey:@"KnJBjybsVgiVDye7pD5YfpyHNOjelIQADFMK447w"];
    
    [Fabric with:@[CrashlyticsKit]];
//    [[Crashlytics sharedInstance] setDebugMode:YES];
    
    [GMSServices provideAPIKey:@"AIzaSyAbXdWCR4ygPVIpQCNq6zW5liZ_22biryg"];
    //==================== Framework initialization ====================
    
    
    // Any significant preloadings/initializations
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        [GANHelper analyzeEvent:@"swipe" label:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] category:@"Notification"];
    }
    
    [DBServerAPI registerUser:nil];
    
    [Venue fetchAllVenuesWithCompletionHandler:^(NSArray *venues) {
        [self saveContext];
    }];
    
    [[DBMenu sharedInstance] updateMenuForVenue:nil remoteMenu:nil];
    
    [Order dropOrdersHistoryIfItIsFirstLaunchOfSomeVersions];
    
    [JRSwizzleMethods swizzleUIViewDealloc];
    //[DBShareHelper sharedInstance];
    
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

    self.window.rootViewController = [DBTabBarController sharedInstance];

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
    //[[DBShareHelper sharedInstance] updateShareInfo];
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

    [self saveContext];

}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [GANHelper analyzeEvent:@"push" label:@"success" category:@"Notification"];

    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
    
    NSNumber *lastOrderId = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastOrderId"];
    if (lastOrderId) {
        [PFPush subscribeToChannelInBackground:[NSString stringWithFormat:@"order_%@", lastOrderId]];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"%s -> %@", __PRETTY_FUNCTION__, error);
    [GANHelper analyzeEvent:@"push" label:@"fail" category:@"Notification"];
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
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
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

@end