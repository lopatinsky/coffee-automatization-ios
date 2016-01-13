//
//  DBUniversalModuleItem.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 29/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBUniversalModuleItem.h"
#import "OrderCoordinator.h"

@implementation DBUniversalModuleItem

- (instancetype)initWithResponseDict:(NSDictionary *)dict{
    self = [super init];
    
    _type = [[dict getValueForKey:@"type"] integerValue];
    _itemId = [dict getValueForKey:@"field"] ?: @"";
    _placeholder = [dict getValueForKey:@"title"] ?: @"";
    _order = [[dict getValueForKey:@"order"] integerValue];
    _jsonField = [dict getValueForKey:@"field"] ?: @"";
    _restrictions = [dict getValueForKey:@"restrictions"] ?: @"";
    
    return self;
}

- (void)syncWithResponseDict:(NSDictionary *)dict{
    _type = [[dict getValueForKey:@"type"] integerValue];
    _placeholder = [dict getValueForKey:@"title"] ?: @"";
    _order = [[dict getValueForKey:@"order"] integerValue];
    _jsonField = [dict getValueForKey:@"field"] ?: @"";
    _restrictions = [dict getValueForKey:@"restrictions"] ?: @"";
}

- (void)save {
    if([self.delegate respondsToSelector:@selector(db_universalModuleHaveChange)]) {
        [self.delegate db_universalModuleHaveChange];
    }
}

- (void)setText:(NSString *)text {
    _text = text;
}

- (BOOL)availableAccordingRestrictions {
    BOOL available = YES;
    
    for (NSDictionary *restriction in _restrictions) {
        if ([restriction[@"type"] integerValue] == 0 && [OrderCoordinator sharedInstance].orderManager.paymentType == [restriction[@"value"] integerValue]) {
            available = NO;
        }
        
        if ([restriction[@"type"] integerValue] == 1 && [OrderCoordinator sharedInstance].deliverySettings.deliveryType.typeId == [restriction[@"value"] integerValue]) {
            available = NO;
        }
    }
    
    return available;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [[[self class] alloc] init];
    if(self != nil){
        _type = [[aDecoder decodeObjectForKey:@"_type"] integerValue];
        _itemId = [aDecoder decodeObjectForKey:@"_itemId"];
        _placeholder = [aDecoder decodeObjectForKey:@"_placeholder"];
        _jsonField = [aDecoder decodeObjectForKey:@"_jsonField"];
        _text = [aDecoder decodeObjectForKey:@"_text"];
        _order = [[aDecoder decodeObjectForKey:@"_order"] integerValue];
        _restrictions = [aDecoder decodeObjectForKey:@"_resctrictions"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:@(_type) forKey:@"_type"];
    [aCoder encodeObject:_itemId forKey:@"_itemId"];
    [aCoder encodeObject:_placeholder forKey:@"_placeholder"];
    [aCoder encodeObject:_jsonField forKey:@"_jsonField"];
    [aCoder encodeObject:_text forKey:@"_text"];
    [aCoder encodeObject:@(_order) forKey:@"_order"];
    [aCoder encodeObject:_restrictions forKey:@"_restrictions"];
}

@end
