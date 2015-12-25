//
//  DBPositionsMenuModuleView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 25/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBMenuModuleView.h"

@class DBMenuCategory;
@interface DBPositionsMenuModuleView : DBMenuModuleView
@property (strong, nonatomic) DBMenuCategory *category;

+ (DBPositionsMenuModuleView *)create;
@end
