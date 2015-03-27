//
//  IHMenuProduct.m
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 18.08.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBMenuPosition.h"
#import "DBMenuPositionModifier.h"

@interface DBMenuPosition ()<NSCoding>
@property(strong, nonatomic) NSMutableArray *groupModifiers;
@end

@implementation DBMenuPosition

+ (instancetype)positionFromResponseDictionary:(NSDictionary *)positionDictionary;{
    DBMenuPosition *product = [DBMenuPosition new];
    
    [product copyFromResponseDictionary:positionDictionary];
    
    product.groupModifiers = [NSMutableArray new];
    for(NSDictionary *modifierDictionary in positionDictionary[@"group_modifiers"]){
        DBMenuPositionModifier *modifier = [DBMenuPositionModifier groupModifierFromDictionary:modifierDictionary];
        if(modifier)
            [product.groupModifiers addObject:modifier];
    }
    
    return product;
}

- (void)synchronizeWithResponseDictionary:(NSDictionary *)positionDictionary{
    [self copyFromResponseDictionary:positionDictionary];
    
    if([_groupModifiers count] != [positionDictionary[@"group_modifiers"] count]){
        _groupModifiers = [NSMutableArray new];
        for(NSDictionary *modifierDictionary in positionDictionary[@"group_modifiers"]){
            [_groupModifiers addObject:[DBMenuPositionModifier groupModifierFromDictionary:modifierDictionary]];
        }
    } else {
        for(int i = 0; i < [_groupModifiers count]; i++){
            DBMenuPositionModifier *modifier = _groupModifiers[i];
            if(![modifier synchronizeGroupModifierWithDictionary:positionDictionary[@"group_modifiers"][0]]){
                [_groupModifiers removeObject:modifier];
            }
        }
    }
}

- (void)copyFromResponseDictionary:(NSDictionary *)positionDictionary{
    _positionId = [positionDictionary getValueForKey:@"id"] ?: @"";
    _name = [positionDictionary getValueForKey:@"title"] ?: @"0";
    _price = [[positionDictionary getValueForKey:@"price"] doubleValue];
    _imageUrl = [positionDictionary getValueForKey:@"pic"];
    _positionDescription = [positionDictionary getValueForKey:@"description"];
    _energyAmount = [[positionDictionary getValueForKey:@"kal"] doubleValue];
    _weight = [[positionDictionary getValueForKey:@"weight"] doubleValue];
    _volume = [[positionDictionary getValueForKey:@"volume"] doubleValue];
    
    _venuesRestrictions = [positionDictionary[@"restrictions"] getValueForKey:@"venues"] ?: @[];
    
    _productDictionary = positionDictionary;
    
    _singleModifiers = [NSMutableArray new];
    for(NSDictionary *modifierDictionary in positionDictionary[@"single_modifiers"]){
        [self.singleModifiers addObject:[DBMenuPositionModifier singleModifierFromDictionary:modifierDictionary]];
    }
}


#pragma mark - NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [[DBMenuPosition alloc] init];
    if(self != nil){
        _positionId = [aDecoder decodeObjectForKey:@"positionId"];
        _name = [aDecoder decodeObjectForKey:@"name"];
        _price = [[aDecoder decodeObjectForKey:@"price"] doubleValue];
        _imageUrl = [aDecoder decodeObjectForKey:@"imageUrl"];
        _positionDescription = [aDecoder decodeObjectForKey:@"positionDescription"];
        _energyAmount = [[aDecoder decodeObjectForKey:@"energyAmount"] doubleValue];
        _weight = [[aDecoder decodeObjectForKey:@"weight"] doubleValue];
        _volume = [[aDecoder decodeObjectForKey:@"volume"] doubleValue];
        _groupModifiers = [aDecoder decodeObjectForKey:@"groupModifiers"];
        _singleModifiers = [aDecoder decodeObjectForKey:@"singleModifiers"];
        _venuesRestrictions = [aDecoder decodeObjectForKey:@"venuesRestrictions"];
        _productDictionary = [aDecoder decodeObjectForKey:@"productDictionary"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.positionId forKey:@"positionId"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:@(self.price) forKey:@"price"];
    [aCoder encodeObject:self.imageUrl forKey:@"imageUrl"];
    [aCoder encodeObject:self.positionDescription forKey:@"positionDescription"];
    [aCoder encodeObject:@(self.energyAmount) forKey:@"energyAmount"];
    [aCoder encodeObject:@(self.weight) forKey:@"weight"];
    [aCoder encodeObject:@(self.volume) forKey:@"volume"];
    [aCoder encodeObject:self.groupModifiers forKey:@"groupModifiers"];
    [aCoder encodeObject:self.singleModifiers forKey:@"singleModifiers"];
    [aCoder encodeObject:self.venuesRestrictions forKey:@"venuesRestrictions"];
    [aCoder encodeObject:self.productDictionary forKey:@"productDictionary"];
}

@end
