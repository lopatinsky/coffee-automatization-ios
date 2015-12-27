//
//  DBPromoCell.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 02.06.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBPromotion;

typedef NS_ENUM(NSInteger, DBPromoCellType) {
    DBPromoCellTypeGeneral = 0,
    DBPromoCellTypePic,
    DBPromoCellTypeImage
};

@interface DBPromoCell : UITableViewCell
@property (nonatomic) DBPromoCellType type;

+ (NSString *)reuseIdentifier:(DBPromoCellType)type;
+ (DBPromoCell *)create:(DBPromoCellType)type;


- (void)configureWithPromo:(DBPromotion *)promo;

@end

