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
#import "OrderPartManagerProtocol.h"

// External notification constants
extern NSString * const DBFriendGiftHelperNotificationFriendName;
extern NSString * const DBFriendGiftHelperNotificationFriendPhone;

extern NSString * const DBFriendGiftHelperNotificationItemsPrice;

typedef NS_ENUM(NSInteger, DBFriendGiftType) {
    DBFriendGiftTypeCommon,
    DBFriendGiftTypeFree
};

@interface DBFriendGiftHelper : DBPrimaryManager<OrderParentManagerProtocol>

@property (nonatomic, readonly) BOOL enabled;
@property (nonatomic, readonly) DBFriendGiftType type;

// Friend Gift info
@property(strong, nonatomic, readonly) NSString *titleFriendGiftScreen;
@property(strong, nonatomic, readonly) NSString *textFriendGiftScreen;
@property(nonatomic, strong) NSArray *giftsHistory;

@property(strong, nonatomic) NSArray *items;
- (void)fetchItems:(void(^)(BOOL success))callback;
- (void)fetchGiftsHistory:(void(^)(BOOL success))callback;


// Data for gift processing
@property (strong, nonatomic) DBUserName *friendName;
@property (strong, nonatomic) DBUserPhone *friendPhone;

@property (strong, nonatomic) OrderItemsManager *itemsManager;

@property (nonatomic) BOOL validData;
- (void)processGift:(void(^)(NSString *smsText))success
            failure:(void(^)(NSString *errorDescription))failure;


@end
