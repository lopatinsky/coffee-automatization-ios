//
//  DBPayPalManager.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 04.06.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DBPayPalBindingState) {
    DBPayPalBindingStateCancelled = 0,
    DBPayPalBindingStateDone = 1,
    DBPayPalBindingStateFailure
};

@class DBPayPalManager;
@protocol DBPayPalManagerDelegate <NSObject>
- (void)payPalManager:(DBPayPalManager *)manager shouldPresentViewController:(UIViewController *)controller;
- (void)payPalManager:(DBPayPalManager *)manager shouldDismissViewController:(UIViewController *)controller;

@end


@interface DBPayPalManager : NSObject
@property (weak, nonatomic) id<DBPayPalManagerDelegate> delegate;

@property (nonatomic, readonly) BOOL loggedIn;
@property (strong, nonatomic, readonly) NSString *paymentMetadata;

+ (instancetype)sharedInstance;

- (void)bindPayPal:(void(^)(DBPayPalBindingState state, NSString *message))callback;
- (void)unbindPayPal:(void(^)())callback;

@end
