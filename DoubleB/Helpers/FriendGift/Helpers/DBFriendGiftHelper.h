//
//  DBShareHelper.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 19.01.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBPrimaryManager.h"
#import "OrderItemsManager.h"
#import "DBUserProperty.h"

// External notification constants
extern NSString * const DBFriendGiftHelperNotificationFriendName;
extern NSString * const DBFriendGiftHelperNotificationFriendPhone;

@interface DBFriendGiftHelper : DBPrimaryManager

// Friend Gift info
@property(strong, nonatomic, readonly) NSString *titleFriendGiftScreen;
@property(strong, nonatomic, readonly) NSString *textFriendGiftScreen;

@property(strong, nonatomic) NSArray *items;


// Data for gift processing
@property (strong, nonatomic) DBUserName *friendName;
@property (strong, nonatomic) DBUserPhone *friendPhone;

@property (strong, nonatomic) OrderItemsManager *itemsManager;

@property (nonatomic) BOOL validData;
- (void)processGift:(void(^)(NSString *smsText))success
            failure:(void(^)(NSString *errorDescription))failure;

// Data after processing gift
@property (strong, nonatomic) NSString *smsText;

@end
