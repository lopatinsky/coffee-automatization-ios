//
//  IHMenuProductModifier.m
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 18.11.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBMenuPositionModifier.h"
#import "DBMenuPositionModifierItem.h"

@interface DBMenuPositionModifier ()<NSCoding>
@property (nonatomic) ModifierType modifierType;
@property (strong, nonatomic) NSString *modifierId;
@property (strong, nonatomic) NSString *modifierName;
@property (strong, nonatomic) NSDictionary *modifierDictionary;

// Only for Single modifier
@property (nonatomic) double modifierPrice;
@property (nonatomic) NSInteger maxAmount;
@property (nonatomic) NSInteger minAmount;

//Only for Group modifiers
@property (strong, nonatomic) NSMutableArray *items;
@end

@implementation DBMenuPositionModifier

- (instancetype)init{
    self = [super init];
    
    _modifierId = @"";
    _modifierName = @"";
    _modifierDictionary = @{};
    
    _modifierPrice = 0;
    _minAmount = 0;
    _maxAmount = 0;
    
    _items = [NSMutableArray new];
    
    return self;
}

+ (DBMenuPositionModifier *)groupModifierFromDictionary:(NSDictionary *)modifierDictionary{
    DBMenuPositionModifier *modifier = [[DBMenuPositionModifier alloc] init];
    
    modifier.modifierType = ModifierTypeGroup;
    modifier.modifierId = modifierDictionary[@"modifier_id"];
    modifier.modifierName = modifierDictionary[@"title"];
    
    for(NSDictionary *itemDict in modifierDictionary[@"choices"]){
        [modifier.items addObject:[DBMenuPositionModifierItem itemFromDictionary:itemDict modifier:modifier]];
    }
    // If no variants to choose, not create modifier
    if([modifier.items count] < 1)
        modifier = nil;
    
    modifier.lastSelectedItem = [modifier.items firstObject];
    
    modifier.modifierDictionary = modifierDictionary;
    
    return modifier;
}

- (BOOL)synchronizeGroupModifierWithDictionary:(NSDictionary *)modifierDictionary{
    self.modifierType = ModifierTypeGroup;
    self.modifierId = modifierDictionary[@"modifier_id"];
    self.modifierName = modifierDictionary[@"title"];
    
    for(NSDictionary *itemDict in modifierDictionary[@"choices"]){
        [self.items addObject:[DBMenuPositionModifierItem itemFromDictionary:itemDict modifier:self]];
    }
    // If no variants to choose, return fail of synchronization
    if([self.items count] < 1)
        return NO;
    
    if(![self.modifierDictionary[@"choices"] isEqualToArray:modifierDictionary[@"choices"]]){
        self.lastSelectedItem = [self.items firstObject];
    }
    
    self.modifierDictionary = modifierDictionary;
    
    return YES;
}


+ (DBMenuPositionModifier *)singleModifierFromDictionary:(NSDictionary *)modifierDictionary{
    DBMenuPositionModifier *modifier = [[DBMenuPositionModifier alloc] init];
    
    modifier.modifierType = ModifierTypeSingle;
    modifier.modifierId = [modifierDictionary getValueForKey:@"modifier_id"] ?: @"";
    modifier.modifierName = [modifierDictionary getValueForKey:@"title"] ?: @"";
    modifier.modifierPrice = [[modifierDictionary getValueForKey:@"price"] doubleValue];
    modifier.minAmount = [[modifierDictionary getValueForKey:@"min"] integerValue];
    modifier.maxAmount = [[modifierDictionary getValueForKey:@"max"] integerValue];
    modifier.modifierDictionary = modifierDictionary; 
    
    return modifier;
}

#pragma mark - NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [[DBMenuPositionModifier alloc] init];
    if(self != nil){
        self.modifierType = [[aDecoder decodeObjectForKey:@"modifierType"] intValue];
        self.modifierId = [aDecoder decodeObjectForKey:@"modifierId"];
        self.modifierName = [aDecoder decodeObjectForKey:@"modifierName"];
        self.minAmount = [[aDecoder decodeObjectForKey:@"minAmount"] integerValue];
        self.maxAmount = [[aDecoder decodeObjectForKey:@"maxAmount"] integerValue];
        self.items = [aDecoder decodeObjectForKey:@"items"];
        self.lastSelectedItem = [aDecoder decodeObjectForKey:@"lastSelectedItem"];
        self.modifierPrice = [[aDecoder decodeObjectForKey:@"modifierPrice"] doubleValue];
        self.modifierDictionary = [aDecoder decodeObjectForKey:@"modifierDictionary"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:@(self.modifierType) forKey:@"modifierType"];
    [aCoder encodeObject:self.modifierId forKey:@"modifierId"];
    [aCoder encodeObject:self.modifierName forKey:@"modifierName"];
    [aCoder encodeObject:@(self.minAmount) forKey:@"minAmount"];
    [aCoder encodeObject:@(self.maxAmount) forKey:@"maxAmount"];
    [aCoder encodeObject:self.items forKey:@"items"];
    [aCoder encodeObject:self.lastSelectedItem forKey:@"lastSelectedItem"];
    [aCoder encodeObject:@(self.modifierPrice) forKey:@"modifierPrice"];
    [aCoder encodeObject:self.modifierDictionary forKey:@"modifierDictionary"];
}

@end
