//
//  DBUserDefaultsManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 27/02/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBUserDefaultsManager.h"

@implementation DBUserDefaultsManager

- (BOOL)showVenuesPopupOnStart {
    NSNumber *object = [DBUserDefaultsManager valueForKey:@"showVenuesPopupOnStart"];
    if (!object) {
        [DBUserDefaultsManager setValue:@(YES) forKey:@"showVenuesPopupOnStart"];
    }
    
    return [[DBUserDefaultsManager valueForKey:@"showVenuesPopupOnStart"] boolValue];
}

- (void)setShowVenuesPopupOnStart:(BOOL)showVenuesPopupOnStart {
    [DBUserDefaultsManager setValue:@(showVenuesPopupOnStart) forKey:@"showVenuesPopupOnStart"];
}

+ (NSString *)db_managerStorageKey {
    return @"DBUserDefaultsManagerDefaultsInfo";
}

@end
