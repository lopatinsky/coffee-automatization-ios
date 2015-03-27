//
//  OrderItem.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 06.12.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "OrderItem.h"
#import "Position.h"
#import "MenuPositionExtension.h"
#import "DBMenuCategory.h"
#import "MenuHelper.h"

@implementation OrderItem

- (instancetype)initWithPosition:(Position *)position{
    self = [super init];
    self.position = position;
    self.selectedExt = nil;
    
    [self commonInit];
    
    return self;
}

- (instancetype)initWithPosition:(Position *)position extension:(MenuPositionExtension *)ext{
    self = [self initWithPosition:position];
    self.selectedExt = ext;
    
    [self commonInit];
    
    return self;
}

+ (instancetype)orderItemFromHistoryDictionary:(NSDictionary *)historyItem{
    OrderItem *item = [[OrderItem alloc] init];
    
    NSString *itemName = historyItem[@"title"];
    NSDictionary *nameAndApp = [[MenuHelper sharedHelper] fetchNameAndExtFromPositionName:itemName price:historyItem[@"price"]];
    //Position *position = [[MenuHelper sharedHelper] findPositionWithName:nameAndApp[@"title"]];
    Position *position = nil;
    item.position = position;
    
    if(nameAndApp[@"ext"]){
        NSArray *exts = position.exts;
        NSString *extId = [NSString stringWithFormat:@"%@", historyItem[@"id"]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"extId == %@", extId];
        MenuPositionExtension *ext = [[exts filteredArrayUsingPredicate:predicate] firstObject];
        item.selectedExt = ext;
    }
    
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
    double total = self.selectedExt ? [self.selectedExt.extPrice doubleValue] : [self.position.price doubleValue];
    
    return total * self.count;
}


#pragma mark - NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [[OrderItem alloc] init];
    if(self != nil){
        self.position = [aDecoder decodeObjectForKey:@"position"];
        self.selectedExt = [aDecoder decodeObjectForKey:@"selectedExt"];
        self.count = [[aDecoder decodeObjectForKey:@"count"] integerValue];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.position forKey:@"position"];
    [aCoder encodeObject:self.selectedExt forKey:@"selectedExt"];
    [aCoder encodeObject:@(self.count) forKey:@"count"];
}

- (id)copyWithZone:(NSZone *)zone{
    OrderItem *orderItem = [[[self class] allocWithZone:zone] init];
    
    orderItem.position = self.position;
    orderItem.selectedExt = self.selectedExt;
    orderItem.count = self.count;
    
    return orderItem;
}

@end
