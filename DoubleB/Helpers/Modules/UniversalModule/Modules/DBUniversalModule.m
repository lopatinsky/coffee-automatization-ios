//
//  DBUniversalModule.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 29/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBUniversalModule.h"
#import "DBUniversalModuleItem.h"

#import "DBUniversalModuleView.h"

@interface DBUniversalModule ()<DBUniversalModuleDelegate>

@end

@implementation DBUniversalModule

- (instancetype)initWithResponseDict:(NSDictionary *)dict {
    self = [super init];
    
    _moduleId = [dict getValueForKey:@"group_field"] ?: @"";
    _title = [dict getValueForKey:@"group_title"] ?: @"";
    _jsonField = [dict getValueForKey:@"group_field"] ?: @"";
    
    NSMutableArray *mutItems = [NSMutableArray new];
    for (NSDictionary *itemDict in dict[@"fields"]) {
        DBUniversalModuleItem *item = [[DBUniversalModuleItem alloc] initWithResponseDict:itemDict];
        item.delegate = self;
        
        [mutItems addObject:item];
    }
    
    [mutItems sortedArrayUsingComparator:^NSComparisonResult(DBUniversalModuleItem *obj1, DBUniversalModuleItem *obj2) {
        return [@(obj1.order) compare:@(obj2.order)];
    }];
    _items = mutItems;
    
    return  self;
}

- (void)syncWithResponseDict:(NSDictionary *)dict {
    _moduleId = [dict getValueForKey:@"group_field"] ?: @"";
    _title = [dict getValueForKey:@"group_title"] ?: @"";
    _jsonField = [dict getValueForKey:@"group_field"] ?: @"";
    
    NSMutableArray *mutItems = [NSMutableArray new];
    
    for (NSDictionary *responseItem in dict[@"fields"]) {
        NSString *fieldId = responseItem[@"field"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemId == %@", fieldId];
        DBUniversalModuleItem *item = [[_items filteredArrayUsingPredicate:predicate] firstObject];
        if(item) {
            [item syncWithResponseDict:responseItem];
            [mutItems addObject:item];
        } else {
            DBUniversalModuleItem *newItem = [[DBUniversalModuleItem alloc] initWithResponseDict:responseItem];
            newItem.delegate = self;
            if(newItem)
                [mutItems addObject:newItem];
        }
    }
    [mutItems sortedArrayUsingComparator:^NSComparisonResult(DBUniversalModuleItem *obj1, DBUniversalModuleItem *obj2) {
        return [@(obj1.order) compare:@(obj2.order)];
    }];
    _items = mutItems;
}

- (NSDictionary *)jsonRepresentation {
    NSMutableDictionary *json = [NSMutableDictionary new];
    
    for (DBUniversalModuleItem *item in _items) {
        json[item.jsonField] = item.text;
    }
    
    return json;
}

- (DBModuleView *)getModuleView {
    return [[DBUniversalModuleView alloc] initWithModule:self];
}


#pragma mark - DBUniversalModuleDelegate

- (void)db_universalModuleHaveChange {
    if([self.delegate respondsToSelector:@selector(db_universalModuleHaveChange)]) {
        [self.delegate db_universalModuleHaveChange];
    }
}


#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [[[self class] alloc] init];
    if(self != nil){
        _moduleId = [aDecoder decodeObjectForKey:@"_moduleId"];
        _title = [aDecoder decodeObjectForKey:@"_title"];
        _jsonField = [aDecoder decodeObjectForKey:@"_jsonField"];
        
        _items = [aDecoder decodeObjectForKey:@"_items"];
        for (DBUniversalModuleItem *item in _items) {
            item.delegate = self;
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_moduleId forKey:@"_moduleId"];
    [aCoder encodeObject:_title forKey:@"_title"];
    [aCoder encodeObject:_jsonField forKey:@"_jsonField"];
    
    [aCoder encodeObject:_items forKey:@"_items"];
}

@end
