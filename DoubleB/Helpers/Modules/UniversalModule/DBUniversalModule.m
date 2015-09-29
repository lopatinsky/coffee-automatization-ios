//
//  DBUniversalModule.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 29/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBUniversalModule.h"
#import "DBUniversalModuleItem.h"

@interface DBUniversalModule ()

@end

@implementation DBUniversalModule

- (instancetype)initWithItems:(NSArray *)items {
    self = [super init];
    
    _items = items;
    
    return  self;
}

- (NSDictionary *)jsonRepresentation {
    NSMutableDictionary *json = [NSMutableDictionary new];
    
    for (DBUniversalModuleItem *item in _items) {
        json[item.jsonField] = item.text;
    }
    
    return json;
}

@end
