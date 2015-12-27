//
//  DBMixedMenuModuleView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 25/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBMenuModuleView.h"

@class DBMenuCategory;

@interface DBMixedMenuModuleView : DBMenuTableModuleView
@property (strong, nonatomic) NSArray *categories;

+ (DBMixedMenuModuleView *)create;

- (void)scrollToCategory:(DBMenuCategory *)category;
@end
