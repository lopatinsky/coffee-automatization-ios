//
//  DBCardsManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 18.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBCardsManager.h"
#import "UICKeyChainStore.h"

@interface DBPaymentCard ()
@property (nonatomic) BOOL isDefault;
@end

@implementation DBPaymentCard
- (instancetype)init:(NSString *)token pan:(NSString *)pan {
    self = [super init];
    _token = token;
    _pan = pan;
    
    return self;
}

#pragma mark - NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [[DBPaymentCard alloc] init];
    if(self != nil){
        _pan = [aDecoder decodeObjectForKey:@"pan"];
        _token = [aDecoder decodeObjectForKey:@"token"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_token forKey:@"token"];
    [aCoder encodeObject:_pan forKey:@"pan"];
}

@end


@implementation DBCardsManager

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static DBCardsManager *instance = nil;
    dispatch_once(&once, ^{ instance = [[self alloc] init]; });
    return instance;
}

- (instancetype)init{
    self = [super init];
    
    [self fetch];
    
    return self;
}

// TODO: write data migration
- (void)fetch {
    NSData *data = [[UICKeyChainStore keyChainStore] dataForKey:@"payment_cards"];
    _cards = [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (void)syncronize {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_cards];
    [[UICKeyChainStore keyChainStore] setData:data forKey:@"cards"];
    [[UICKeyChainStore keyChainStore] synchronize];
}

- (NSUInteger)cardsCount {
    return [_cards count];
}

- (DBPaymentCard *)defaultCard {
    DBPaymentCard *result;
    for(DBPaymentCard *card in _cards) {
        if(card.isDefault)
            result = card;
    }
    
    if(!result && self.cardsCount > 0){
        self.defaultCard = [_cards firstObject];
        result = [_cards firstObject];
    }
    
    return result;
}

- (void)setDefaultCard:(DBPaymentCard *)defaultCard {
    for(DBPaymentCard *card in _cards) {
        if(card == defaultCard){
            card.isDefault = YES;
        } else {
            card.isDefault = NO;
        }
    }
}

- (DBPaymentCard *)cardAtIndex:(NSUInteger)index {
    return index < self.cardsCount ? _cards[index] : nil;
}

- (BOOL)addCard:(DBPaymentCard *)card {
    BOOL response = YES;
    for(DBPaymentCard *storedCard in _cards)
        response &= ![storedCard.pan isEqualToString:card.pan];
    
    if(response){
        [_cards addObject:card];
        self.defaultCard = card;
        [self syncronize];
    }
    
    return response;
}

- (void)removeCard:(DBPaymentCard *)card {
    [_cards removeObject:card];
}

- (void)removeCardAtIndex:(NSUInteger)index {
    if(index < self.cardsCount)
        [_cards removeObjectAtIndex:index];
}

@end
