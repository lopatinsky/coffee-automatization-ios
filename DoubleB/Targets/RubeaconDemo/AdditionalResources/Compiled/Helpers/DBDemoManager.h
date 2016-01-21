//
//  DBDemoManager.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 30/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBPrimaryManager.h"

typedef NS_ENUM(NSInteger, DBDemoManagerState) {
    DBDemoManagerStateNone = 0,
    DBDemoManagerStateDemo,
    DBDemoManagerStateCompany
};

@interface DBDemoManager : DBPrimaryManager
@property (nonatomic) DBDemoManagerState state;
@end
