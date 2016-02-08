//
//  Compatibility.m
//  DoubleB
//
//  Created by Sergey Pronin on 7/31/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "Compatibility.h"

@implementation Compatibility

+ (NSString *)currencySymbol {
    if ([UIDevice systemVersionGreaterOrEqualsThan:@"8.0"]) {
        return @"₽";
    } else {
        return NSLocalizedString(@"р.", nil);
    }
}

+ (void)registerForNotifications {
    if ([UIDevice systemVersionGreaterOrEqualsThan:@"8.0"]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        SILENCE_IOS8_DEPRECATION(
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
        );
    }
}

+ (BOOL)isRegisteredForRemoteNotification {
    if([UIDevice systemVersionGreaterOrEqualsThan:@"8.0"]) {
        return [UIApplication sharedApplication].isRegisteredForRemoteNotifications;
    } else {
        SILENCE_IOS8_DEPRECATION(
            return [UIApplication sharedApplication].enabledRemoteNotificationTypes == (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound);
        );
    }
}

@end
