//
//  DBSushilarCategoryCell.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 27/01/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBSushilarCategoryCell.h"
#import "UIView+RoundedCorners.h"

@implementation DBSushilarCategoryCell

+ (instancetype)create:(DBCategoryCellAppearanceType)type {
    if (type == DBCategoryCellAppearanceTypeFull)
        return [[[NSBundle mainBundle] loadNibNamed:@"DBSushilarCategoryCell" owner:self options:nil] firstObject];
    else
        return [[[NSBundle mainBundle] loadNibNamed:@"DBCategoryCompactCell" owner:self options:nil] firstObject];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.categoryIconImageView setRoundedCornersWithRadius:self.categoryIconImageView.frame.size.height / 2];
}

+ (CGFloat)height:(DBCategoryCellAppearanceType)type {
    if (type == DBCategoryCellAppearanceTypeFull) {
        return 60.f;
    } else {
        return 65.f;
    }
}

@end
