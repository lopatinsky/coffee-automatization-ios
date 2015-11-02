//
//  DBCardsManager.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 18.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBPrimaryManager.h"
#import "ManagerProtocol.h"

extern NSString *const kDBCardTypeMasterCard;
extern NSString *const kDBCardTypeVisa;
extern NSString *const kDBCardTypeMaestro;
extern NSString *const kDBCardTypeDinersClub;

@interface DBPaymentCard : NSObject<NSCoding>
@property (strong, nonatomic, readonly) NSString *token;
@property (strong, nonatomic, readonly) NSString *pan;
@property (strong, nonatomic, readonly) NSString *cardIssuer;

- (instancetype)init:(NSString *)token pan:(NSString *)pan;
@end


extern NSString * const DBCardsManagerNotificationCardsChanged;

@interface DBCardsManager : DBPrimaryManager <ManagerProtocol>

@property (strong, nonatomic, readonly) NSMutableArray *cards;
@property (nonatomic, readonly) NSUInteger cardsCount;

@property (strong, nonatomic) DBPaymentCard *defaultCard;

- (DBPaymentCard *)cardAtIndex:(NSUInteger)index;
- (BOOL)addCard:(DBPaymentCard *)card;
- (void)removeCard:(DBPaymentCard *)card;
- (void)removeCardAtIndex:(NSUInteger)index;

- (void)fetchWithOldFormat;
@end
