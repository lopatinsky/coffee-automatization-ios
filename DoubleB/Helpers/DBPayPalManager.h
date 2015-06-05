//
//  DBPayPalManager.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 04.06.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBPayPalManager;
@protocol DBPayPalManagerDelegate <NSObject>
- (void)payPalManager:(DBPayPalManager *)manager shouldPresentViewController:(UIViewController *)controller;
- (void)payPalManager:(DBPayPalManager *)manager shouldDismissViewController:(UIViewController *)controller;

@end


@interface DBPayPalManager : NSObject
@property (weak, nonatomic) id<DBPayPalManagerDelegate> delegate;

+ (instancetype)sharedInstance;

- (void)authorize;
@end
