//
//  DBTextResourcesHelper.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 14.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBTextResourcesHelper : NSObject

+ (NSString *)db_venuesTitleString;
+ (NSString *)db_venueTitleString:(int)wordCase;
+ (NSString *)db_venueBalanceString;

+ (NSString *)db_preparationOrderCellString;
+ (NSString *)db_readyOrderCellString;

+ (NSString *)db_bgImageName;
+ (NSString *)db_shareBgImageName;
+ (UIColor *)db_shareScreenTextColor;

+ (NSString *)db_initialMenuTitle;

@end
