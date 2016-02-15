//
//  DBSettingsSection.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 14/02/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBSettingsItem.h"

typedef NS_ENUM(NSInteger, DBSettingsSectionType) {
    DBSettingsSectionTypeUser = 0,
    DBSettingsSectionTypeCompany,
    DBSettingsSectionTypeLoyalty,
    DBSettingsSectionTypeApp,
    
    DBSettingsSectionTypeOther
};

@interface DBSettingsSection : NSObject
@property (nonatomic, readonly) DBSettingsSectionType type;
@property (strong, nonatomic) NSMutableArray<DBSettingsItemProtocol> *items;

- (instancetype)init:(DBSettingsSectionType)type;
@end
