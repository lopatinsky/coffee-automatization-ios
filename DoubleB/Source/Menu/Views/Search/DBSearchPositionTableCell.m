//
//  DBSearchPositionTableCell.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 10/02/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBSearchPositionTableCell.h"
#import "DBMenuPosition.h"

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
    
    self.positionImageView.contentMode = [ViewManager defaultMenuPositionIconsContentMode];
    self.positionImageView.noImageType = [DBCompanyInfo sharedInstance].type == DBCompanyTypeMobileShop ? DBImageViewNoImageTypeText : DBImageViewNoImageTypeImage;
}

- (void)configureWithPosition:(DBMenuPosition *)position{
    _position = position;
    
    self.titleLabel.text = position.name;
    
    if (position.imageUrl) {
        self.positionImageView.dbImageUrl = [NSURL URLWithString:position.imageUrl];
    } else {
        self.positionImageView.dbImageUrl = nil;
    }
    
    self.priceLabel.text = [NSString stringWithFormat:@"%.0f %@", position.price, [Compatibility currencySymbol]];
}

@end
