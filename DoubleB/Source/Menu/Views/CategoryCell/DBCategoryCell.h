//
//  IHCategoryTableViewCell.h
//  IIko Hackathon
//
//  Created by Balaban Alexander on 04/04/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBImageView.h"

typedef NS_ENUM(NSUInteger, DBCategoryCellAppearanceType) {
    DBCategoryCellAppearanceTypeCompact = 0,
    DBCategoryCellAppearanceTypeFull
};

@class DBMenuCategory;

@protocol DBCategoryCellProtocol <NSObject>

+ (instancetype)create:(DBCategoryCellAppearanceType)type;
- (void)configureWithCategory:(DBMenuCategory *)category;

+ (CGFloat)height:(DBCategoryCellAppearanceType)type;

@end

@interface DBCategoryCell : UITableViewCell<DBCategoryCellProtocol>
@property (weak, nonatomic) DBImageView *categoryIconImageView;
@property (weak, nonatomic) UILabel *categoryNameLabel;
@property (weak, nonatomic) UIImageView *disclosureIndicator;

@property (nonatomic) DBCategoryCellAppearanceType appearanceType;
@property (strong, nonatomic, readonly) DBMenuCategory *category;


@end
