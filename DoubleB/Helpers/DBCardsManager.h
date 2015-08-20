//
//  DBCardsManager.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 18.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotificationSubscriptionManager.h"
#import "ManagerProtocol.h"

@interface DBPaymentCard : NSObject<NSCoding>
@property (strong, nonatomic, readonly) NSString *token;
@property (strong, nonatomic, readonly) NSString *pan;

- (instancetype)init:(NSString *)token pan:(NSString *)pan;
@end


extern NSString * const DBCardsManagerNotificationCardsChanged;

@interface DBCardsManager : NotificationSubscriptionManager <ManagerProtocol>
+ (instancetype)sharedInstance;

@property (strong, nonatomic, readonly) NSMutableArray *cards;
@property (nonatomic, readonly) NSUInteger cardsCount;

@property (strong, nonatomic) DBPaymentCard *defaultCard;

- (DBPaymentCard *)cardAtIndex:(NSUInteger)index;
- (BOOL)addCard:(DBPaymentCard *)card;
- (void)removeCard:(DBPaymentCard *)card;
- (void)removeCardAtIndex:(NSUInteger)index;
@end
