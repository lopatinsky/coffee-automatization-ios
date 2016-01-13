//
//  DBUniversalModuleItem.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 29/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBUniversalModuleItem.h"

@implementation DBUniversalModuleItem

- (instancetype)initWithResponseDict:(NSDictionary *)dict{
    self = [super init];
    
    _itemId = [dict getValueForKey:@"field"] ?: @"";
    _placeholder = [dict getValueForKey:@"title"] ?: @"";
    _order = [[dict getValueForKey:@"order"] integerValue];
    _jsonField = [dict getValueForKey:@"field"] ?: @"";
    _restrictions = [dict getValueForKey:@"restrictions"] ?: @"";
    
    return self;
}

- (void)syncWithResponseDict:(NSDictionary *)dict{
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

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [[[self class] alloc] init];
    if(self != nil){
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
    [aCoder encodeObject:_itemId forKey:@"_itemId"];
    [aCoder encodeObject:_placeholder forKey:@"_placeholder"];
    [aCoder encodeObject:_jsonField forKey:@"_jsonField"];
    [aCoder encodeObject:_text forKey:@"_text"];
    [aCoder encodeObject:@(_order) forKey:@"_order"];
    [aCoder encodeObject:_restrictions forKey:@"_restrictions"];
}

@end
