//
//  DBCustomViewManager.m
//  DoubleB
//
//  Created by Balaban Alexander on 18/01/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBCustomViewManager.h"
#import "DBCustomItem.h"

@interface DBCustomViewManager()

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic) BOOL enabled;

@end

@implementation DBCustomViewManager

- (instancetype)init {
    if (self = [super init]) {
        [self loadItems];
        self.enabled = [[DBCustomViewManager valueForKey:@"__enabled"] boolValue];
    }
    return self;
}

- (void)loadItems {
    self.items = [NSMutableArray arrayWithArray:
                  [NSKeyedUnarchiver unarchiveObjectWithData:[DBCustomViewManager valueForKey:@"__customViewItems"]] ?: @[]];
}

- (void)saveItems {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.items];
    [DBCustomViewManager setValue:data forKey:@"__customViewItems"];
}

- (void)enableModule:(BOOL)enabled withDict:(NSDictionary *)moduleDict {
    self.enabled = enabled;
    [DBCustomViewManager setValue:@(enabled) forKey:@"__enabled"];
    
    _items = [NSMutableArray new];
    if (self.enabled) {
        for (NSDictionary *item in [moduleDict objectForKey:@"sections"]) {
            DBCustomItem *newItem = [[DBCustomItem alloc] initWithTitle:[item objectForKey:@"title"] andURLString:[item objectForKey:@"url"]];
            [_items addObject:newItem];
        }
    }
    [self saveItems];
}

- (BOOL)available {
    return self.enabled && [self.items count];
}

- (NSArray *)items {
    return [_items copy];
}

#pragma mark - DBDataManager
+ (NSString *)db_managerStorageKey {
    return @"kDBDefaultsDBCustomViewManager";
}

@end
