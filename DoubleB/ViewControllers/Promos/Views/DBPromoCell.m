//
//  DBPromoCell.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 02.06.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBPromoCell.h"
#import "OrderCoordinator.h"

#import "UIImageView+WebCache.h"

@interface DBPromoCell ()
@property (strong, nonatomic) UIView *imageHolder;
@property (strong, nonatomic) UIImageView *picImageView;

@property (strong, nonatomic) UILabel *titleLabel;

@property (nonatomic) BOOL imageHidden;
@end

@implementation DBPromoCell

+ (NSString *)reuseIdentifier:(DBPromoCellType)type {
    switch (type) {
        case DBPromoCellTypeGeneral:
            return @"DBPromoCell";
        case DBPromoCellTypePic:
            return @"DBPromoPicCell";
        case DBPromoCellTypeImage:
            return @"DBPromoImageCell";
    }
}

+ (DBPromoCell *)create:(DBPromoCellType)type {
    DBPromoCell *cell = [[[NSBundle mainBundle] loadNibNamed:[DBPromoCell reuseIdentifier:type] owner:self options:nil] firstObject];
    cell.type = type;
    [cell commonInit];
    
    return cell;
}


- (void)commonInit {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.imageHolder = [self.contentView viewWithTag:2];
    self.picImageView = [self.imageHolder viewWithTag:21];
    self.titleLabel = [self.contentView viewWithTag:1];
    
    if (_type == DBPromoCellTypeImage) {
        self.picImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.picImageView.layer.borderWidth = 0.5;
        self.picImageView.layer.cornerRadius = 6.f;
        self.picImageView.layer.masksToBounds = YES;
    }
}

- (void)configureWithPromo:(DBPromotion *)promo {
    [self.picImageView sd_setImageWithURL:[NSURL URLWithString:promo.imageUrl]];
    
    NSMutableString *text = [[NSMutableString alloc] initWithString:promo.promotionName];
    if (promo.promotionName.length > 0 && promo.promotionDescription.length > 0) {
        [text appendString:@"\n"];
    }
    [text appendString:promo.promotionDescription];
    
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:text];
    [attrText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue" size:15.f] range:NSMakeRange(0, promo.promotionName.length)];
    [attrText addAttribute:NSForegroundColorAttributeName value:[UIColor db_defaultColor] range:NSMakeRange(0, promo.promotionName.length)];
    
    self.titleLabel.attributedText = attrText;
}


@end
