//
//  DBUniversalModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 29/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBUniversalModuleView.h"
#import "DBUniversalModule.h"
#import "DBUniversalModuleItem.h"

#import "DBModuleHeaderView.h"
#import "DBUniversalModuleTextItemView.h"

@interface DBUniversalModuleView ()

@end

@implementation DBUniversalModuleView

- (instancetype)initWithModule:(DBUniversalModule *)module {
    self = [super init];
    
    _module = module;
    
    [self commonInit];
    
    return self;
}

- (void)commonInit {
    [super commonInit];
    
    if (_module.title.length > 0) {
        DBModuleHeaderView *headerView = [DBModuleHeaderView new];
        headerView.title = _module.title;
        
        [self.submodules addObject:headerView];
    }
    
    for (DBUniversalModuleItem *item in _module.items) {
        DBUniversalModuleTextItemView *itemView = [[DBUniversalModuleTextItemView alloc] initWithItem:item];
        [self.submodules addObject:itemView];
    }
    
    [self layoutModules];
}


@end
