//
//  OrderManager.m
//  DoubleB
//
//  Created by Sergey Pronin on 7/31/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "OrderManager.h"
#import "OrderItem.h"
#import "DBMenuPosition.h"
#import "DBMenuBonusPosition.h"
#import "Venue.h"
#import "IHSecureStore.h"
#import "DBAPIClient.h"
#import "IHPaymentManager.h"
#import "DBPromoManager.h"
#import "DBClientInfo.h"
#import "DBCompanyInfo.h"
#import "DBShippingManager.h"

//#import <Crashlytics/Crashlytics.h>

NSString* const kDBDefaultsPaymentType = @"kDBDefaultsPaymentType";

@interface OrderManager ()
@end

@implementation OrderManager

/**
* Stored in UserDefaults
*/
- (PaymentType)paymentType {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *pt = [defaults objectForKey:kDBDefaultsPaymentType];
    PaymentType paymentType = pt ? (PaymentType)pt.integerValue : PaymentTypeNotSet;
    NSArray *availablePaymentTypes = [defaults objectForKey:kDBDefaultsAvailablePaymentTypes];
    return [availablePaymentTypes containsObject:@(paymentType)] ? paymentType : PaymentTypeNotSet;
}

- (void)setPaymentType:(PaymentType)paymentType {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(paymentType) forKey:kDBDefaultsPaymentType];
    [defaults synchronize];
}

+ (instancetype)sharedManager {
    static dispatch_once_t once;
    static OrderManager *instance = nil;
    dispatch_once(&once, ^{ instance = [[self alloc] init]; });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.items = [NSMutableArray new];
        self.totalPrice = 0;
        
        NSString *lastVenueId = [[NSUserDefaults standardUserDefaults] stringForKey:kDBDefaultsLastSelectedVenue];
        _venue = [Venue venueById:lastVenueId];
        
        self.bonusPositions = [NSMutableArray new];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(purgePositions) name:kDBNewOrderCreatedNotification object:nil];
    }
    return self;
}

- (void)setVenue:(Venue *)venue{
    if(venue){
        _venue = venue;
        [[NSUserDefaults standardUserDefaults] setObject:venue.venueId forKey:kDBDefaultsLastSelectedVenue];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (BOOL)validOrder{
    BOOL result = true;
    
    if([DBDeliverySettings sharedInstance].deliveryType.typeId == DeliveryTypeIdShipping){
        result = result && [DBShippingManager sharedManager].validAddress;
    } else {
        result = result && self.venue;
    }
    result = result && !(self.paymentType == PaymentTypeNotSet);
    result = result && [[DBClientInfo sharedInstance] validClientName];
    result = result && [[DBClientInfo sharedInstance] validClientPhone];
    result = result && [[[NSUserDefaults standardUserDefaults] objectForKey:kDBDefaultsNDASigned] boolValue];
    result = result && (self.totalCount + [self.bonusPositions count]) > 0;
    result = result && [DBPromoManager sharedManager].validOrder;
    
    return result;
}

- (void)reset {
    self.paymentType = PaymentTypeNotSet;
    self.venue = nil;
}

- (void)addBonusPosition:(DBMenuBonusPosition *)bonusPosition{
    OrderItem *itemWithSamePosition;
    
    for(OrderItem *item in self.bonusPositions){
        if([item.position isEqual:bonusPosition]){
            itemWithSamePosition = item;
            break;
        }
    }
    
    if (!itemWithSamePosition) {
        itemWithSamePosition = [[OrderItem alloc] initWithPosition:[bonusPosition copy]];
        itemWithSamePosition.count = 1;
        [self.bonusPositions addObject:itemWithSamePosition];
    } else {
        itemWithSamePosition.count ++;
    }
}

- (void)removeBonusPosition:(DBMenuBonusPosition *)bonusPosition{
    OrderItem *item;
    
    for(OrderItem *orderItem in self.bonusPositions){
        if([orderItem.position isEqual:bonusPosition]){
            item = orderItem;
            break;
        }
    }
    [self.bonusPositions removeObject:item];
}

- (void)removeBonusPositionAtIndex:(NSUInteger)index{
    if(index < self.bonusPositionsCount){
        [self.bonusPositions removeObjectAtIndex:index];
    }
}

- (NSUInteger)bonusPositionsCount{
    return [self.bonusPositions count];
}

- (double)totalBonusPositionsPrice{
    double total = 0;
    for(OrderItem *bonusItem in self.bonusPositions){
        DBMenuBonusPosition *bonusPosition = (DBMenuBonusPosition *)bonusItem.position;
        total += bonusPosition.pointsPrice * bonusItem.count;;
    }
    
    return total;
}

- (void)purgePositions {
    self.items = [NSMutableArray array];
    self.venue = nil;
    self.comment = @"";
    self.location = nil;
    
    self.bonusPositions = [NSMutableArray new];
    
    self.totalPrice = 0;
}

- (void)overridePositions:(NSArray *)items {
    self.items = [NSMutableArray array];
    
    for (OrderItem *item in items) {
        OrderItem *newItem = [item copy];
        [self.items addObject:newItem];
    }
    
    [self reloadTotal];
}

- (NSInteger)addPosition:(DBMenuPosition *)position {
    // Main logic
    DBMenuPosition *copyPosition = [position copy];
    OrderItem *itemWithSamePosition;
    
    for(OrderItem *item in self.items){
        if([item.position isEqual:copyPosition]){
            itemWithSamePosition = item;
            break;
        }
    }
    
    NSInteger currentCount;
    if (!itemWithSamePosition) {
        itemWithSamePosition = [[OrderItem alloc] initWithPosition:copyPosition];
        itemWithSamePosition.count = 1;
        [self.items addObject:itemWithSamePosition];
        currentCount = 1;
    } else {
        itemWithSamePosition.count ++;
        currentCount = itemWithSamePosition.count;
    }
    
    [self reloadTotal];
    
    return currentCount;
}

- (NSInteger)replaceOrderItem:(OrderItem *)item withPosition:(DBMenuPosition *)position{
    DBMenuPosition *copyPosition = [position copy];
    item.position = copyPosition;
    
    NSInteger index = -1;
    for(OrderItem *orderItem in self.items){
        if(orderItem != item && [orderItem.position isEqual:copyPosition]){
            item.count += orderItem.count;
            index = [self.items indexOfObject:orderItem];
            [self.items removeObject:orderItem];
            
            break;
        }
    }
    
    [self reloadTotal];
    
    return index;
}

- (NSInteger)increaseOrderItemCountAtIndex:(NSInteger)index{
    if(index < 0 || index >= [self.items count])
        return 0;
    
    OrderItem *orderItem = self.items[index];
    orderItem.count++;
    
    [self reloadTotal];
    
    return orderItem.count;

}

- (NSInteger)decreaseOrderItemCountAtIndex:(NSInteger)index {
    if(index < 0 || index >= [self.items count])
        return 0;
    
    OrderItem *orderItem = self.items[index];
    orderItem.count--;
    if(orderItem.count < 1){
        [self.items removeObject:orderItem];
    }
    
    [self reloadTotal];
    
    return orderItem.count;
}

- (void)removeOrderItemAtIndex:(NSInteger)index{
    [self.items removeObjectAtIndex:index];
    
    [self reloadTotal];
}

- (NSUInteger)positionsCount {
    return [self.items count];
}

- (NSUInteger)amountOfOrderPositionAtIndex:(NSInteger)index{
    if(index < 0 || index >= [self.items count])
        return 0;
    
    return ((OrderItem *)self.items[index]).count;
}

- (OrderItem *)itemAtIndex:(NSUInteger)index {
    return self.items[index];
}

- (OrderItem *)itemWithPositionId:(NSString *)positionId{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"position.positionId == %@", positionId];
    OrderItem *item =[[self.items filteredArrayUsingPredicate:predicate] firstObject];
    
    return item;
}

- (OrderItem *)itemWithTemplatePosition:(DBMenuPosition *)templatePosition{
    OrderItem *result;
    for(OrderItem *item in self.items){
        if([item.position isEqual:templatePosition]){
            result = item;
            break;
        }
    }
    
    return result;
}


- (void)reloadTotal{
    // Reload initial total
    double total = 0;
    for (OrderItem *item in self.items) {
        total += item.totalPrice;
    }
    self.totalPrice = total;
}

- (NSUInteger)totalCount {
    NSUInteger count = 0;
    for (OrderItem *item in self.items) {
        count += item.count;
    }
    return count;
}

+ (NSUInteger)totalCountForItems:(NSArray *)items{
    NSUInteger count = 0;
    for (OrderItem *item in items) {
        count += item.count;
    }
    return count;
}

- (void)selectIfPossibleDefaultPaymentType{
    NSArray *availablePaymentTypes = [[NSUserDefaults standardUserDefaults] objectForKey:kDBDefaultsAvailablePaymentTypes];
    
    if(self.paymentType == PaymentTypeNotSet && [availablePaymentTypes containsObject:@(PaymentTypeCard)]){
        NSDictionary *defaultCard = [[IHSecureStore sharedInstance] defaultCard];
        if(defaultCard){
            self.paymentType = PaymentTypeCard;
        }
    }
    
    if(self.paymentType == PaymentTypeNotSet && [availablePaymentTypes containsObject:@(PaymentTypeCash)]){
        self.paymentType = PaymentTypeCash;
    }
}

@end



@interface DBDeliverySettings ()
@property (strong, nonatomic) DBDeliveryType *lastNotShippingDeliveryType;

// Time management
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation DBDeliverySettings

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static DBDeliverySettings *instance = nil;
    dispatch_once(&once, ^{ instance = [[self alloc] init]; });
    return instance;
}

- (instancetype)init{
    self = [super init];
    
    self.deliveryType = [[DBCompanyInfo sharedInstance].deliveryTypes firstObject];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(companyInfoUpdateHandler:) name:kDBFirstLaunchNecessaryInfoLoadSuccessNotification object:nil];
    
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)companyInfoUpdateHandler:(NSNotification *)notification{
    if(!self.deliveryType)
        self.deliveryType = [[DBCompanyInfo sharedInstance].deliveryTypes firstObject];
}

#pragma mark - Delivery type

- (void)selectDeliveryType:(DBDeliveryType *)type{
    if(type.typeId == DeliveryTypeIdShipping){
        self.lastNotShippingDeliveryType = self.deliveryType;
    }
    
    self.deliveryType = type;
    switch (self.deliveryType.typeId) {
        case DeliveryTypeIdInRestaurant:
            [GANHelper analyzeEvent:@"delivery_type_selected" label:@"InRestaurant" category:ADDRESS_SCREEN];
            break;
        case DeliveryTypeIdTakeaway:
            [GANHelper analyzeEvent:@"delivery_type_selected" label:@"Takeaway" category:ADDRESS_SCREEN];
            break;
        default:
            break;
    }
}

- (void)selectShipping{
    if(self.deliveryType && self.deliveryType.typeId != DeliveryTypeIdShipping)
        self.lastNotShippingDeliveryType = self.deliveryType;
    
    self.deliveryType = [[DBCompanyInfo sharedInstance] deliveryTypeById:DeliveryTypeIdShipping];
    [GANHelper analyzeEvent:@"delivery_type_selected" label:@"Shipping" category:ADDRESS_SCREEN];
}

- (void)selectTakeout{
    if(self.lastNotShippingDeliveryType)
        self.deliveryType = self.lastNotShippingDeliveryType;
    
    self.deliveryType = [[DBCompanyInfo sharedInstance] deliveryTypeById:DeliveryTypeIdTakeaway];
    [GANHelper analyzeEvent:@"delivery_type_selected" label:@"Takeout" category:ADDRESS_SCREEN];
}

- (void)setDeliveryType:(DBDeliveryType *)deliveryType{
    _deliveryType = deliveryType;
    
    if(_deliveryType.timeMode & (TimeModeTime | TimeModeDateTime)){
        [self launchTimer];
    } else {
        [self stopTimer];
    }
    
    [self updateTimeAccordingToDeliveryType];
}


#pragma mark - Time management

- (void)launchTimer{
    if(!self.timer){
        long long seconds = [[NSDate date] timeIntervalSince1970];
        seconds = seconds - seconds % 60 + 60 + 1;
        self.timer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSince1970:seconds] interval:15.f
                                                target:self
                                              selector:@selector(timerTick:)
                                              userInfo:nil
                                               repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
        [self timerTick:self.timer];
    }
}

- (void)stopTimer{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)updateTimeAccordingToDeliveryType{
    if(_deliveryType.timeMode & (TimeModeTime | TimeModeDateTime | TimeModeDateSlots)){
        if(!self.selectedTime || [self.selectedTime compare:_deliveryType.minDate] == NSOrderedAscending){
            self.selectedTime = _deliveryType.minDate;
        }
        
        if([self.selectedTime compare:_deliveryType.maxDate] == NSOrderedDescending){
            self.selectedTime = _deliveryType.maxDate;
        }
    }
    
    if(self.deliveryType.timeMode & (TimeModeSlots | TimeModeDateSlots)){
        DBTimeSlot *timeSlot = [_deliveryType timeSlotWithName:self.selectedTimeSlot.slotTitle];
        if(!timeSlot)
            timeSlot = [_deliveryType.timeSlots firstObject];
        
        self.selectedTimeSlot = timeSlot;
    }
}

- (void)timerTick:(NSTimer *)timer{
    self.minimumTime = [[NSDate date] dateByAddingTimeInterval:self.deliveryType.minTimeInterval];
    [self reloadTime];
}

- (void)reloadTime{
    if(!self.selectedTime || [self.selectedTime compare:self.minimumTime] != NSOrderedDescending){
        self.selectedTime = self.minimumTime;
    }
}

- (NSInteger)setNewSelectedTime:(NSDate *)date{
    NSInteger result;
    
    result = [date compare:self.deliveryType.minDate];
    
    if(result != NSOrderedAscending){
        result = [date compare:self.deliveryType.maxDate];
        if(result != NSOrderedDescending){
            _selectedTime = date;
            result = NSOrderedSame;
        } else {
            _selectedTime = self.deliveryType.maxDate;
        }
    } else {
        _selectedTime = self.deliveryType.minDate;
    }
    
    return result;
}

- (void)reset{
    self.deliveryType = nil;
    self.selectedTimeSlot = nil;
    self.selectedTime = nil;
    self.lastNotShippingDeliveryType = nil;
}

@end