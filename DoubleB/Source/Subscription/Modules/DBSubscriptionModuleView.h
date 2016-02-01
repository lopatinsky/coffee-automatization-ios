//
//  DBSubscriptionModuleView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 14/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBModuleView.h"

#import "DBCategoryCell.h"
#import "DBPositionCell.h"

typedef NS_ENUM(NSInteger, DBSubscriptionModuleViewMode) {
    DBSubscriptionModuleViewModeCategory = 0,
    DBSubscriptionModuleViewModeCategoriesAndPositions,
    DBSubscriptionModuleViewModePositions
};

@interface DBSubscriptionModuleView : DBModuleView
@property (nonatomic) DBSubscriptionModuleViewMode mode;

+ (DBSubscriptionModuleView*)create:(DBSubscriptionModuleViewMode)mode;
- (void)pushSubscriptionViewController;

@end
