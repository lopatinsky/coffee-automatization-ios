//
//  DBCardsManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 18.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBCardsManager.h"
#import "IHSecureStore.h"

NSString *const kDBCardTypeMasterCard = @"MasterCard";
NSString *const kDBCardTypeVisa = @"Visa";
NSString *const kDBCardTypeMaestro = @"Maestro";
NSString *const kDBCardTypeDinersClub = @"Diners Club";

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

- (NSString *)cardIssuer {
    NSString *result = @"";
    NSString *check = [self.pan substringWithRange:NSMakeRange(0, 2)];
    if(check.intValue == 34 || check.intValue == 37) result = @"American Express";
    if(check.intValue == 36) result = kDBCardTypeDinersClub;
    if(check.intValue == 38) result = @"Carte Blanche";
    if(check.intValue >= 51 && check.intValue <= 55) result = kDBCardTypeMasterCard;
    
    if([result isEqualToString:@""]){
        check = [self.pan substringWithRange:NSMakeRange(0, 4)];
        NSSet *maestroPans = [NSSet setWithObjects:@"5018", @"5020", @"5038", @"5612", @"5893", @"6304", @"6759", @"6761", @"6762", @"6763", @"0604", @"6390", nil];
        if([maestroPans containsObject:check]) result = kDBCardTypeMaestro;
        if(check.intValue == 2014 || check.intValue == 2149) result = @"EnRoute";
        if(check.intValue == 2131 || check.intValue == 1800) result = @"JCB";
        if(check.intValue == 6011) result = @"Discover";
        
        if([result isEqualToString:@""]){
            check = [self.pan substringWithRange:NSMakeRange(0, 3)];
            if(check.intValue >= 300 && check.intValue <= 305) result = kDBCardTypeDinersClub;
            
            if([result isEqualToString:@""]){
                check = [self.pan substringWithRange:NSMakeRange(0, 1)];
                if(check.intValue == 3) result = @"JCB";
                if(check.intValue == 4) result = kDBCardTypeVisa;
            }
        }
    }
    
    if([result isEqualToString:@""]) result = @"Unknown";
    
    return result;
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



NSString * const DBCardsManagerNotificationCardsChanged = @"DBCardsManagerNotificationCardsChanged";

@interface DBCardsManager ()
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
    NSData *data = [[IHSecureStore sharedInstance] dataForKey:@"payment_cards"];
    _cards = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if(!_cards)
        [self fetchWithOldFormat];
    
    if(!_cards)
        _cards = [NSMutableArray new];
}

// Data migration from old format
- (void)fetchWithOldFormat {
    NSData *data = [[IHSecureStore sharedInstance] dataForKey:@"cards"];
    NSArray *cards = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    _cards = [NSMutableArray new];
    for(NSDictionary *cardDict in cards){
        NSString *token = cardDict[@"cardToken"];
        NSString *pan = cardDict[@"cardPan"];
        DBPaymentCard *card = [[DBPaymentCard alloc] init:token pan:pan];
        card.isDefault = [cardDict[@"default"] boolValue];
        
        [_cards addObject:card];
    }
    
    [self syncronize];
}

- (void)syncronize {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_cards];
    [[IHSecureStore sharedInstance] setData:data forKey:@"payment_cards"];
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
    
    [self notifyObserver];
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
    
    [self notifyObserver];
    
    return response;
}

- (void)removeCard:(DBPaymentCard *)card {
    [_cards removeObject:card];
    [self syncronize];
    
    [self notifyObserver];
}

- (void)removeCardAtIndex:(NSUInteger)index {
    if(index < self.cardsCount) {
        [_cards removeObjectAtIndex:index];
        [self notifyObserver];
    }
}

- (void)notifyObserver {
    [self notifyObserverOf:DBCardsManagerNotificationCardsChanged];
}

#pragma mark - ManagerProtocol

- (void)flushCache {
    
}

- (void)flushStoredCache {
    [self flushCache];
}

@end
