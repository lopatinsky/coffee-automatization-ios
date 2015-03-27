//
//  Position.m
//  DoubleB
//
//  Created by Sergey Pronin on 7/31/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "Position.h"
#import "MenuPositionExtension.h"

@interface Position () <NSCoding>

@end

@implementation Position

+ (instancetype)positionWithDictionary:(NSDictionary *)dictionary {
    Position *pos = [Position new];
    [pos setValuesForKeysWithDictionary:dictionary];
    pos.exts = [NSMutableArray new];
    return pos;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"id"] || [key isEqualToString:@"item_id"]) {
        _positionId = value;
    } else if ([key isEqualToString:@"description"]) {
        _descr = value;
    /*} else if ([key isEqualToString:@"quantity"]) {
        _count = [value integerValue];*/
    } else if ([key isEqualToString:@"name"]) {
        _title = value;
    } else {
        [super setValue:value forKey:key];
    }
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        return [((Position *)object).positionId isEqualToString:self.positionId];
    } else {
        return [super isEqual:object];
    }
}

- (NSString *)extNameAtIndex:(NSInteger)index{
    if(index >= 0 && index < [self.exts count]){
        return ((MenuPositionExtension *)self.exts[index]).extName;
    } else {
        return nil;
    }
}

#pragma mark - NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [[Position alloc] init];
    if(self != nil){
        self.positionId = [aDecoder decodeObjectForKey:@"positionId"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.descr = [aDecoder decodeObjectForKey:@"descr"];
        self.pic = [aDecoder decodeObjectForKey:@"pic"];
        self.price = [aDecoder decodeObjectForKey:@"price"];
        self.kal = [aDecoder decodeObjectForKey:@"kal"];
        self.exts = [aDecoder decodeObjectForKey:@"exts"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.positionId forKey:@"positionId"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.descr forKey:@"descr"];
    [aCoder encodeObject:self.pic forKey:@"pic"];
    [aCoder encodeObject:self.price forKey:@"price"];
    [aCoder encodeObject:self.kal forKey:@"kal"];
    [aCoder encodeObject:self.exts forKey:@"exts"];
}

@end
