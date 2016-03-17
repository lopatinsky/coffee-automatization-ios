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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableModule) name:kDBModulesManagerModulesLoaded object:nil];
        [self enableModule];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadItems {
    self.items = [NSMutableArray arrayWithArray:
                  [NSKeyedUnarchiver unarchiveObjectWithData:[DBCustomViewManager valueForKey:@"__customViewItems"]] ?: @[]];
}

- (void)saveItems {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.items];
    [DBCustomViewManager setValue:data forKey:@"__customViewItems"];
}

- (void)enableModule {
    DBModule *module = [[DBModulesManager sharedInstance] module:DBModuleTypeCustomView];
    self.enabled = module != nil;
    [DBCustomViewManager setValue:@(_enabled) forKey:@"__enabled"];
    
    _items = [NSMutableArray new];
    if (self.enabled) {
        for (NSDictionary *item in [module.info objectForKey:@"sections"]) {
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
