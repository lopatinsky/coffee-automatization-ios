//
//  OrderItem.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 06.12.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "OrderItem.h"
#import "DBMenuPosition.h"
#import "DBMenu.h"

@implementation OrderItem

- (instancetype)initWithPosition:(DBMenuPosition *)position{
    self = [super init];
    self.position = position;
    
    [self commonInit];
    
    return self;
}

+ (instancetype)orderItemFromHistoryDictionary:(NSDictionary *)historyItem{
    OrderItem *item = [[OrderItem alloc] init];
    
    DBMenuPosition *position = [[DBMenu sharedInstance] findPositionWithId:@"id"];
    item.position = position;
    
    item.count = [historyItem[@"quantity"] integerValue];
    
    [item commonInit];
    
    return item;
}

- (void)commonInit{
    [self clearAdditionalInfo];
}

- (void)setNotes:(NSArray *)notes{
    _notes = notes;
    _errors = @[];
}

- (void)setErrors:(NSArray *)errors{
    _errors = errors;
}

- (void)clearAdditionalInfo{
    _notes = @[];
    _errors = @[];
}

- (BOOL)shouldShowAdditionalInfo{
    return [_notes count] > 0 || [_errors count] > 0;
}

- (NSArray *)messages{
    if([_errors count] > 0){
        return _errors;
    } else {
        return _notes;
    }
}

- (double)totalPrice{
    return self.position.price * self.count;
}


#pragma mark - NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [[OrderItem alloc] init];
    if(self != nil){
        self.position = [aDecoder decodeObjectForKey:@"position"];
        self.count = [[aDecoder decodeObjectForKey:@"count"] integerValue];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.position forKey:@"position"];
    [aCoder encodeObject:@(self.count) forKey:@"count"];
}

- (id)copyWithZone:(NSZone *)zone{
    OrderItem *orderItem = [[[self class] allocWithZone:zone] init];
    
    orderItem.position = self.position;
    orderItem.count = self.count;
    
    return orderItem;
}

@end
