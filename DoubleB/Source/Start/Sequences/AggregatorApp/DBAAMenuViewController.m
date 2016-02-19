//
//  DBUACommonMenuViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 16/02/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBAAMenuViewController.h"
#import "DBAACompanyInfoMenuModuleView.h"

@interface DBAAMenuViewController ()

@end

@implementation DBAAMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSArray *)setupTopModules {
    NSMutableArray *modules = [[NSMutableArray alloc] initWithArray:[super setupTopModules]];
    
    [modules insertObject:[self setupCompanyInfoModule] atIndex:0];
    
    return modules;
}

- (DBModuleView *)setupCompanyInfoModule {
    if (self.type == DBMenuViewControllerTypeInitial) {
        DBAACompanyInfoMenuModuleView *infoModule = [DBAACompanyInfoMenuModuleView create];
        infoModule.ownerViewController = self;
        infoModule.analyticsCategory = self.analyticsCategory;
        return infoModule;
    }
    
    return nil;
}

- (UIBarButtonItem *)leftBarButtonItem {
    return nil;
}

@end
