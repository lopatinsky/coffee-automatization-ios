//
//  DBDemoManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 30/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBDemoManager.h"

@implementation DBDemoManager

- (instancetype)init {
    self = [super init];
    
    self.state = [[DBDemoManager valueForKey:@"managerState"] integerValue];
    
    return self;
}

+ (NSString *)db_managerStorageKey {
    return @"kDBDefaultsDemoManager";
}

- (void)setState:(DBDemoManagerState)state {
    [DBDemoManager setValue:@(state) forKey:@"managerState"];
}

@end
