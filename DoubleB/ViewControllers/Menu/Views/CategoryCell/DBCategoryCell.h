//
//  IHCategoryTableViewCell.h
//  IIko Hackathon
//
//  Created by Balaban Alexander on 04/04/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DBCategoryCellAppearanceType) {
    DBCategoryCellAppearanceTypeCompact = 0,
    DBCategoryCellAppearanceTypeFull
};

@class DBMenuCategory;

@interface DBCategoryCell : UITableViewCell
@property (strong, nonatomic, readonly) DBMenuCategory *category;

- (instancetype)initWithType:(DBCategoryCellAppearanceType)type;
- (void)configureWithCategory:(DBMenuCategory *)category;

@end
