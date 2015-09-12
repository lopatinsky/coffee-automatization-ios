//
//  DBPaymentModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 19.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBModuleView.h"

@interface DBModuleView ()

@end

@implementation DBModuleView

- (void)awakeFromNib {
    self.submodules = [NSMutableArray new];
}

- (void)reload{
    [self reload:NO];
}

- (void)reload:(BOOL)animated {
    for(DBModuleView *module in _submodules){
        [module reload:animated];
    }
}

- (void)setAnalyticsCategory:(NSString *)analyticsCategory{
    _analyticsCategory = analyticsCategory;
    
    for(DBModuleView *submodule in self.submodules){
        submodule.analyticsCategory = analyticsCategory;
    }
}

- (void)setOwnerViewController:(UIViewController *)ownerViewController{
    _ownerViewController = ownerViewController;
    
    for(DBModuleView *submodule in self.submodules){
        submodule.ownerViewController = ownerViewController;
    }
}

- (CGSize)intrinsicContentSize {
    return [self moduleViewContentSize];
}


- (CGSize)moduleViewContentSize {
    return self.frame.size;
}

@end
