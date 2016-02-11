//
//  DBSearchManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 11/02/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBSearchManager.h"
#import "DBMenu.h"
#import "OrderCoordinator.h"

@implementation DBSearchManager

- (NSString *)searchText {
    return [DBSearchManager valueForKey:@"menuSearchText"];
}

- (NSArray *)filterPositions:(NSString *)text {
    [DBSearchManager setValue:text forKey:@"menuSearchText"];
    
    return [[DBMenu sharedInstance] filterPositions:text
                                              venue:[OrderCoordinator sharedInstance].orderManager.venue];
}


+ (NSString *)db_managerStorageKey {
    return @"kDBSearchManagerDefaults";
}

@end
