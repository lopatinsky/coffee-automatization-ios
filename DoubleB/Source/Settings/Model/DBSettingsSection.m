//
//  DBSettingsSection.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 14/02/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBSettingsSection.h"

@implementation DBSettingsSection

- (instancetype)init:(DBSettingsSectionType)type {
    self = [super init];
    
    _type = type;
    _items = [NSMutableArray<DBSettingsItemProtocol> new];
    
    return self;
}
@end
