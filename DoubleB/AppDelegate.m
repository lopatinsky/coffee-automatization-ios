//
//  AppDelegate.m
//  DoubleB
//
//  Created by Sergey Pronin on 6/21/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "AppDelegate.h"
#import "IHSecureStore.h"
#import "DBTabBarController.h"
#import "JRSwizzleMethods.h"
#import "ApplicationManager.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <GoogleMaps/GoogleMaps.h>
#import <Parse/Parse.h>
#import <PayPal-iOS-SDK/PayPalMobile.h>
#import <FBSDKApplicationDelegate.h>
#import <FBSDKAppEvents.h>
#import <VKSdk.h>

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // TODO: change forceCopy to false after test
    if([[DBCompanyInfo sharedInstance].bundleName.lowercaseString isEqualToString:@"coffeeautomation"]){
        [ApplicationManager copyPlistWithName:@"CompanyInfo" forceCopy:false];
    } else {
        [ApplicationManager copyPlistWithName:@"CompanyInfo" forceCopy:true];
    }
    [[ApplicationManager sharedInstance] initializeVendorFrameworks];
    [[ApplicationManager sharedInstance] startApplicationWithOptions:launchOptions];
    
    if ([DBCompanyInfo sharedInstance].companyPushChannel) {
        [PFPush subscribeToChannelInBackground:[DBCompanyInfo sharedInstance].companyPushChannel];
    }
    
    [ApplicationManager applyBrandbookStyle];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[ApplicationManager sharedInstance] rootViewController];
    
    [self.window makeKeyAndVisible];
    
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        [GANHelper analyzeEvent:@"swipe" label:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] category:@"Notification"];
        
        [[DBTabBarController sharedInstance] awakeFromRemoteNotification];
        
        NSDictionary *userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        UIViewController<PopupNewsViewControllerProtocol> *newsViewController = [ViewControllerManager newsViewController];
        [newsViewController setData:@{@"text": [userInfo[@"aps"] getValueForKey:@"alert"] ?: @"", @"image_url": @""}];
        [[UIViewController currentViewController] presentViewController:newsViewController animated:YES completion:nil];
    }
    
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [VKSdk processOpenURL:url fromApplication:sourceApplication];
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation
                    ];
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
    [FBSDKAppEvents activateApp];
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
    [GANHelper analyzeEvent:@"push" label:@"success" category:@"Notification"];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
    
    NSNumber *lastOrderId = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastOrderId"];
    if (lastOrderId) {
        [PFPush subscribeToChannelInBackground:[NSString stringWithFormat:[DBCompanyInfo sharedInstance].orderPushChannel, lastOrderId]];
    }
    
    [PFPush subscribeToChannelInBackground:[DBCompanyInfo sharedInstance].companyPushChannel];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
    
    if([UIApplication sharedApplication].applicationState != 0){
        UIViewController<PopupNewsViewControllerProtocol> *newsViewController = [ViewControllerManager newsViewController];
        [newsViewController setData:@{@"text": [userInfo[@"aps"] getValueForKey:@"alert"] ?: @"", @"image_url": @""}];
        [[UIViewController currentViewController] presentViewController:newsViewController animated:YES completion:nil];
    }
    
    NSNotification *notification = [NSNotification notificationWithName:kDBStatusUpdatedNotification
                                                                 object:nil
                                                               userInfo:userInfo ?: @{}];

    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
    // TODO: publish remote notification with popup view controller
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
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

@end