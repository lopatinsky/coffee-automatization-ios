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
        [modifier.items addObject:[DBMenuPositionModifierItem itemFromDictionary:itemDict]];
    }
    [modifier sortItems];
    
    // If no variants to choose, not create modifier
    if([modifier.items count] < 1)
        modifier = nil;
    
    modifier.selectedItem = [modifier.items firstObject];
    
    modifier.modifierDictionary = modifierDictionary;
    
    return modifier;
}

- (BOOL)synchronizeGroupModifierWithDictionary:(NSDictionary *)modifierDictionary{
    self.modifierType = ModifierTypeGroup;
    self.modifierId = modifierDictionary[@"modifier_id"];
    self.modifierName = modifierDictionary[@"title"];
    
    self.items = [NSMutableArray new];
    for(NSDictionary *itemDict in modifierDictionary[@"choices"]){
        [self.items addObject:[DBMenuPositionModifierItem itemFromDictionary:itemDict]];
    }
    [self sortItems];
    
    // If no variants to choose, return fail of synchronization
    if([self.items count] < 1)
        return NO;
    
    if(![self.modifierDictionary[@"choices"] isEqualToArray:modifierDictionary[@"choices"]]){
        self.selectedItem = [self.items firstObject];
    }
    
    self.modifierDictionary = modifierDictionary;
    
    return YES;
}

- (void)sortItems{
    [self.items sortUsingComparator:^NSComparisonResult(DBMenuPositionModifierItem *obj1, DBMenuPositionModifierItem *obj2) {
        return [@(obj1.itemPrice) compare:@(obj2.itemPrice)];
    }];
}

- (void)selectItemAtIndex:(NSInteger)index{
    if(index >= 0 && index < [self.items count]){
        DBMenuPositionModifierItem *selectedItem = self.items[index];
        self.selectedItem = selectedItem;
    }
}

- (void)clearSelectedItem{
    self.selectedItem = nil;
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

- (void)selectItemById:(NSString *)itemId{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemId == %@", itemId];
    DBMenuPositionModifierItem *item = [[self.items filteredArrayUsingPredicate:predicate] firstObject];
    if(item){
        self.selectedItem = item;
    }
}

- (double)actualPrice{
    if(self.modifierType == ModifierTypeGroup){
        return self.selectedItem.itemPrice;
    } else {
        return self.selectedCount * self.modifierPrice;
    }
}

- (BOOL)isSameModifier:(DBMenuPositionModifier *)object{
    if(![object isKindOfClass:[DBMenuPositionModifier class]]){
        return NO;
    }
    
    return [self.modifierDictionary isEqualToDictionary:((DBMenuPositionModifier *)object).modifierDictionary];
}

- (BOOL)isEqual:(DBMenuPositionModifier *)object{
    BOOL result = [self isSameModifier:object];
    
    if(result){
        if(self.modifierType == ModifierTypeGroup){
            result = result && [self.selectedItem isEqual:object.selectedItem];
        } else {
            result = result && (self.selectedCount == object.selectedCount);
        }
    }
    
    return result;
}

- (NSUInteger)hash{
    return [self.modifierDictionary hash];
}


#pragma mark - NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [[DBMenuPositionModifier alloc] init];
    if(self != nil){
        self.modifierType = [[aDecoder decodeObjectForKey:@"modifierType"] intValue];
        self.modifierId = [aDecoder decodeObjectForKey:@"modifierId"];
        self.modifierName = [aDecoder decodeObjectForKey:@"modifierName"];
        self.modifierDictionary = [aDecoder decodeObjectForKey:@"modifierDictionary"];
        
        self.minAmount = [[aDecoder decodeObjectForKey:@"minAmount"] integerValue];
        self.maxAmount = [[aDecoder decodeObjectForKey:@"maxAmount"] integerValue];
        self.modifierPrice = [[aDecoder decodeObjectForKey:@"modifierPrice"] doubleValue];
        self.selectedCount = [[aDecoder decodeObjectForKey:@"selectedCount"] intValue];
        
        self.required = [[aDecoder decodeObjectForKey:@"required"] boolValue];
        self.items = [aDecoder decodeObjectForKey:@"items"];
        self.selectedItem = [aDecoder decodeObjectForKey:@"selectedItem"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:@(self.modifierType) forKey:@"modifierType"];
    [aCoder encodeObject:self.modifierId forKey:@"modifierId"];
    [aCoder encodeObject:self.modifierName forKey:@"modifierName"];
    [aCoder encodeObject:self.modifierDictionary forKey:@"modifierDictionary"];
    
    [aCoder encodeObject:@(self.minAmount) forKey:@"minAmount"];
    [aCoder encodeObject:@(self.maxAmount) forKey:@"maxAmount"];
    [aCoder encodeObject:@(self.modifierPrice) forKey:@"modifierPrice"];
    [aCoder encodeObject:@(self.selectedCount) forKey:@"selectedCount"];
    
    [aCoder encodeObject:@(self.required) forKey:@"required"];
    [aCoder encodeObject:self.items forKey:@"items"];
    [aCoder encodeObject:self.selectedItem forKey:@"selectedItem"];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone{
    DBMenuPositionModifier *copyModifier = [[[self class] allocWithZone:zone] init];
    copyModifier.modifierType = self.modifierType;
    copyModifier.modifierId = [self.modifierId copy];
    copyModifier.modifierName = [self.modifierName copy];
    copyModifier.modifierDictionary = [self.modifierDictionary copy];
    
    copyModifier.modifierPrice = self.modifierPrice;
    copyModifier.maxAmount = self.maxAmount;
    copyModifier.minAmount = self.minAmount;
    copyModifier.selectedCount = self.selectedCount;
    
    copyModifier.required = self.required;
    copyModifier.items = [NSMutableArray new];
    for(DBMenuPositionModifierItem *item in self.items)
        [copyModifier.items addObject:[item copyWithZone:zone]];
    
    copyModifier.selectedItem = [self.selectedItem copyWithZone:zone];
    
    return copyModifier;
}

@end
