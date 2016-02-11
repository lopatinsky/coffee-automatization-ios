//
//  DBSearchPositionTableCell.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 10/02/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBSearchPositionTableCell.h"
#import "DBMenuPosition.h"
#import "UIView+RoundedCorners.h"

@interface DBSearchPositionTableCell ()
@property (weak, nonatomic) IBOutlet DBImageView *positionImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintImageViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTitleLabelLeading;

@end

@implementation DBSearchPositionTableCell

+ (DBSearchPositionTableCell *)create {
    DBSearchPositionTableCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"DBSearchPositionTableCell" owner:self options:nil] firstObject];
    
    return cell;
}

- (void)awakeFromNib {
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor whiteColor];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.positionImageView setRoundedCornersWithRadius:self.positionImageView.frame.size.width / 2];
    self.positionImageView.contentMode = [ViewManager defaultMenuPositionIconsContentMode];
    self.positionImageView.noImageType = [DBCompanyInfo sharedInstance].type == DBCompanyTypeMobileShop ? DBImageViewNoImageTypeText : DBImageViewNoImageTypeImage;
}

- (void)configureWithPosition:(DBMenuPosition *)position{
    _position = position;
    
    self.titleLabel.text = position.name;
    
    if (position.imageUrl) {
        self.positionImageView.dbImageUrl = [NSURL URLWithString:position.imageUrl];
        self.constraintImageViewWidth.constant = 35;
        self.constraintTitleLabelLeading.constant = 8;
    } else {
        self.constraintImageViewWidth.constant = 0;
        self.constraintTitleLabelLeading.constant = 0;
    }
    
    self.priceLabel.text = [NSString stringWithFormat:@"%.0f %@", position.price, [Compatibility currencySymbol]];
}

@end
