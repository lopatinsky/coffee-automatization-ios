//
//  DBUnifiedAppNavController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBUnifiedAppNavController.h"
#import "DBUnifiedAppManager.h"

#import "DBCitiesViewController.h"

@interface DBUnifiedAppNavController ()

@end

@implementation DBUnifiedAppNavController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (![DBUnifiedAppManager selectedCity]) {
        self.viewControllers = @[[DBCitiesViewController new]];
    } else {
        
    }
}


@end
