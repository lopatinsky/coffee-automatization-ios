//
//  IHMenuProductModifierItem.m
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 18.11.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBMenuPositionModifierItem.h"
#import "DBMenuPositionModifier.h"

@interface DBMenuPositionModifierItem ()<NSCoding>
@end

@implementation DBMenuPositionModifierItem

+ (DBMenuPositionModifierItem *)itemFromDictionary:(NSDictionary *)itemDictionary
                                          modifier:(DBMenuPositionModifier *)modifier;{
    DBMenuPositionModifierItem *item = [[DBMenuPositionModifierItem alloc] init];
    
    [item setValuesForKeysWithDictionary:itemDictionary];
    item.modifier = modifier;
    item.itemDictionary = itemDictionary;
    
    return item;
}

- (void)setValue:(id)value forKey:(NSString *)key{
    if([key isEqual:@"id"]){
        self.itemId = value ?: @"";
    }
    if([key isEqual:@"title"] || [key isEqual:@"name"]){
        self.itemName = value ?: @"";
    }
    if([key isEqual:@"price"]){
        self.itemPrice = value ? [value doubleValue] : 0;
    }
}

#pragma mark - NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [[DBMenuPositionModifierItem alloc] init];
    if(self != nil){
        self.itemId = [aDecoder decodeObjectForKey:@"itemId"];
        self.itemName = [aDecoder decodeObjectForKey:@"itemName"];
        self.itemPrice = [[aDecoder decodeObjectForKey:@"itemPrice"] doubleValue];
        self.modifier = [aDecoder decodeObjectForKey:@"modifier"];
        self.itemDictionary = [aDecoder decodeObjectForKey:@"itemDictionary"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.itemId forKey:@"itemId"];
    [aCoder encodeObject:self.itemName forKey:@"itemName"];
    [aCoder encodeObject:@(self.itemPrice) forKey:@"itemPrice"];
    [aCoder encodeObject:self.modifier forKey:@"modifier"];
    [aCoder encodeObject:self.itemDictionary forKey:@"itemDictionary"];
}

- (BOOL)isEqual:(id)object{
    if(![object isKindOfClass:[DBMenuPositionModifierItem class]]){
        return NO;
    }
    
    return [self.itemDictionary isEqualToDictionary:((DBMenuPositionModifierItem *)object).itemDictionary];
}

- (NSUInteger)hash{
    return [self.itemDictionary hash];
}

@end
