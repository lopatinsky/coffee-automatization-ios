//
//  DBCategoriesMenuModuleView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 25/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBMenuModuleView.h"

@class DBMenuCategory;
@interface DBCategoriesMenuModuleView : DBMenuModuleView

@property (strong, nonatomic) DBMenuCategory *parent;
@property (strong, nonatomic) NSArray *categories;

+ (DBCategoriesMenuModuleView *)create;
@end
