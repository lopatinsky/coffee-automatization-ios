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
@property (nonatomic) NSInteger order;

//Only for Group modifiers
@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) DBMenuPositionModifierItem *defaultItem;
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

#pragma mark - Dynamic data

- (double)actualPrice{
    if(self.modifierType == ModifierTypeGroup){
        double actualPrice = self.defaultItem.itemPrice;
        
        if(self.selectedItem)
            actualPrice = self.selectedItem.itemPrice;
        
        return actualPrice;
    } else {
        return self.selectedCount * self.modifierPrice;
    }
}


#pragma mark - GroupModifier

+ (DBMenuPositionModifier *)groupModifierFromDictionary:(NSDictionary *)modifierDictionary{
    DBMenuPositionModifier *modifier = [[DBMenuPositionModifier alloc] init];
    [modifier copyGroupModifierFromDictionary:modifierDictionary];
    
    // If no variants to choose, not create modifier
    if([modifier.items count] < 1)
        modifier = nil;
    
    return modifier;
}

- (BOOL)synchronizeGroupModifierWithDictionary:(NSDictionary *)modifierDictionary{
    [self copyGroupModifierFromDictionary:modifierDictionary];
    
    // Check in current selectedItem is in new _items
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemId == %@", self.selectedItem.itemId];
    self.selectedItem = [[_items filteredArrayUsingPredicate:predicate] firstObject];
    
    // If no variants to choose, return error of synchronization
    if([self.items count] < 1)
        return NO;
    
    return YES;
}

- (void)copyGroupModifierFromDictionary:(NSDictionary *)modifierDictionary {
    self.modifierType = ModifierTypeGroup;
    self.modifierId = modifierDictionary[@"modifier_id"];
    self.modifierName = modifierDictionary[@"title"];
    
    self.required = [[modifierDictionary getValueForKey:@"required"] boolValue];
    
    // Reload items
    self.items = [NSMutableArray new];
    for(NSDictionary *itemDict in modifierDictionary[@"choices"]){
        DBMenuPositionModifierItem *modifierItem = [DBMenuPositionModifierItem itemFromDictionary:itemDict];
        [self.items addObject:modifierItem];
        
        // Select Default choice
        if([[itemDict getValueForKey:@"default"] boolValue]){
            self.defaultItem = modifierItem;
        }
    }
    [self sortItems];
    
    // If no default choice, select first choice
    if(self.items.count > 0 && self.required && !self.defaultItem){
        self.defaultItem = [self.items firstObject];
    }
    
    self.modifierDictionary = modifierDictionary;
}

- (void)sortItems{
    [self.items sortUsingComparator:^NSComparisonResult(DBMenuPositionModifierItem *obj1, DBMenuPositionModifierItem *obj2) {
        return [@(obj1.order) compare:@(obj2.order)];
    }];
}

- (void)selectItemAtIndex:(NSInteger)index{
    if(index >= 0 && index < [self.items count]){
        DBMenuPositionModifierItem *selectedItem = self.items[index];
        self.selectedItem = selectedItem;
    }
}

- (void)selectItemById:(NSString *)itemId{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemId == %@", itemId];
    DBMenuPositionModifierItem *item = [[self.items filteredArrayUsingPredicate:predicate] firstObject];
    if(item){
        self.selectedItem = item;
    }
}

- (void)selectDefaultItem {
    if(self.defaultItem)
        self.selectedItem = self.defaultItem;
}

- (void)clearSelectedItem{
    self.selectedItem = nil;
}


#pragma mark - SingleModifier

+ (DBMenuPositionModifier *)singleModifierFromDictionary:(NSDictionary *)modifierDictionary{
    DBMenuPositionModifier *modifier = [[DBMenuPositionModifier alloc] init];
    
    modifier.modifierType = ModifierTypeSingle;
    modifier.modifierId = [modifierDictionary getValueForKey:@"modifier_id"] ?: @"";
    modifier.modifierName = [modifierDictionary getValueForKey:@"title"] ?: @"";
    modifier.modifierPrice = [[modifierDictionary getValueForKey:@"price"] doubleValue];
    modifier.minAmount = [[modifierDictionary getValueForKey:@"min"] integerValue];
    modifier.maxAmount = [[modifierDictionary getValueForKey:@"max"] integerValue];
    modifier.order = [[modifierDictionary getValueForKey:@"order"] integerValue];
    modifier.modifierDictionary = modifierDictionary; 
    
    return modifier;
}


#pragma mark - Equality

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
        self.order = [[aDecoder decodeObjectForKey:@"order"] integerValue];
        self.selectedCount = [[aDecoder decodeObjectForKey:@"selectedCount"] intValue];
        
        self.required = [[aDecoder decodeObjectForKey:@"required"] boolValue];
        self.items = [aDecoder decodeObjectForKey:@"items"];
        self.defaultItem = [aDecoder decodeObjectForKey:@"defaultItem"];
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
    [aCoder encodeObject:@(self.order) forKey:@"order"];
    [aCoder encodeObject:@(self.selectedCount) forKey:@"selectedCount"];
    
    [aCoder encodeObject:@(self.required) forKey:@"required"];
    [aCoder encodeObject:self.items forKey:@"items"];
    
    if(self.defaultItem)
        [aCoder encodeObject:self.defaultItem forKey:@"defaultItem"];
    
    if(self.selectedItem)
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
    copyModifier.order = self.order;
    
    copyModifier.required = self.required;
    copyModifier.items = [NSMutableArray new];
    for(DBMenuPositionModifierItem *item in self.items)
        [copyModifier.items addObject:[item copyWithZone:zone]];
    
    copyModifier.defaultItem = [self.defaultItem copyWithZone:zone];
    copyModifier.selectedItem = [self.selectedItem copyWithZone:zone];
    
    return copyModifier;
}

@end
