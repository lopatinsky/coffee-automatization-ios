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

@interface DBUniversalModule ()

@end

@implementation DBUniversalModule

- (instancetype)initWithItems:(NSArray *)items {
    self = [super init];
    
    NSMutableArray *mutItems = [[NSMutableArray alloc] initWithArray:items];
    [mutItems sortedArrayUsingComparator:^NSComparisonResult(DBUniversalModuleItem *obj1, DBUniversalModuleItem *obj2) {
        return [@(obj1.order) compare:@(obj2.order)];
    }];
    _items = mutItems;
    
    return  self;
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

@end
