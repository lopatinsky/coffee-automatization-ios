//
//  ApplicationManager.h
//  
//
//  Created by Balaban Alexander on 28/07/15.
//
//

#import <Foundation/Foundation.h>

@interface ApplicationManager : NSObject

+ (nonnull UIViewController *)rootViewController;
+ (void)copyPlists;

@end

@interface ApplicationManager(Initialization)

+ (void)initializeVendorFrameworks;
+ (void)initializeOrderFramework;

@end

@interface ApplicationManager(Appearance)

+ (void)applyBrandbookStyle;

@end