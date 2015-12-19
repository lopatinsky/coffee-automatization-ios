//
//  DBStartNavController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBStartNavController.h"

@implementation DBStartNavController

- (instancetype)initWithDelegate:(id<DBStartNavControllerDelegate>)navDelegate {
    self = [super init];
    
    _navDelegate = navDelegate;
    
    return self;
}

@end
