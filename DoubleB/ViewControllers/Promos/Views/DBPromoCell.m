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

@property (strong, nonatomic) UIView *separator;

@property (nonatomic) BOOL imageHidden;
@end

@implementation DBPromoCell

- (instancetype)init{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBPromoCell" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    self.imageHolder = [self.contentView viewWithTag:1];
    self.picImageView = [self.imageHolder viewWithTag:11];
    self.titleLabel = [self.contentView viewWithTag:2];
    self.separator = [self.contentView viewWithTag:5];
}

- (void)configureWithPromo:(DBPromotion *)promo {
    if (promo.imageUrl.length > 0) {
        self.imageHidden = NO;
        [self.picImageView sd_setImageWithURL:[NSURL URLWithString:promo.imageUrl]];
    } else {
        self.imageHidden = YES;
    }
    
    NSMutableString *text = [[NSMutableString alloc] initWithString:promo.promotionName];
    if (promo.promotionName.length > 0 && promo.promotionDescription.length > 0) {
        [text appendString:@"\n"];
    }
    [text appendString:promo.promotionDescription];
    
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:text];
    [attrText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue" size:15.f] range:NSMakeRange(0, promo.promotionName.length)];
    
//    self.titleLabel.attributedText = attrText;
    self.titleLabel.text = @"asgsdngksd\nksjbgskjgn\nkdsbgkjg\nsdjkgksjdg\ndjksbgkjs\nkdsgjksdg\ndsjkgsdjg";
}

- (void)setImageHidden:(BOOL)imageHidden {
    _imageHidden = imageHidden;
    
    NSLayoutConstraint *constraintWidth = [self imageHolderWidthConstraint];
    if (_imageHidden) {
        constraintWidth.constant = 0;
    } else {
        constraintWidth.constant = 48.f;
    }
}

- (NSLayoutConstraint *)imageHolderWidthConstraint {
    for (NSLayoutConstraint *constr in self.imageHolder.constraints) {
        if ([constr.identifier isEqualToString:@"imageHolderWidth"]) {
            return constr;
        }
    }
    
    return nil;
}


@end
