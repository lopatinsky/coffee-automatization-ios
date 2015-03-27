//
//  Menu.m
//  DoubleB
//
//  Created by Dmitriy Stupivtsev on 06.02.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBMenuCategory.h"
#import "Position.h"

@interface DBMenuCategory ()
@end

@implementation DBMenuCategory
+ (instancetype) category:(id)categoryId name:(NSString *)categoryName items:(NSArray *)items {
    DBMenuCategory *menu = [DBMenuCategory new];
    menu.categoryId = categoryId;
    menu.categoryName = categoryName;
    menu.items = items;
    
    return menu;
}

#pragma mark - NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [DBMenuCategory new];
    if (self != nil) {
        self.categoryName = [aDecoder decodeObjectForKey:@"categoryName"];
        self.items = [aDecoder decodeObjectForKey:@"items"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.categoryName forKey:@"categoryName"];
    [aCoder encodeObject:self.items forKey:@"items"];
}
@end