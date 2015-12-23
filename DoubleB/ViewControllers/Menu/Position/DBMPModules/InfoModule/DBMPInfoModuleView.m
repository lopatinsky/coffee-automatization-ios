//
//  DBMPInfoModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 19/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBMPInfoModuleView.h"

#import "DBMenuPosition.h"

@interface DBMPInfoModuleView ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UILabel *energyLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation DBMPInfoModuleView

+ (DBMPInfoModuleView *)create {
    DBMPInfoModuleView *view = [[[NSBundle mainBundle] loadNibNamed:@"DBMPInfoModuleView" owner:self options:nil] firstObject];
    
    return view;
}

- (void)awakeFromNib {
    self.priceLabel.textColor = [UIColor db_defaultColor];
}

- (void)setPosition:(DBMenuPosition *)position {
    _position = position;
    
    [self reload:NO];
}

- (void)reload:(BOOL)animated {
    [super reload:animated];
    
    self.titleLabel.text = self.position.name;
    self.descriptionLabel.text = self.position.positionDescription;
    
    self.weightLabel.text = @"";
    if(self.position.weight > 0){
        self.weightLabel.text = [NSString stringWithFormat:@"%.0f %@", self.position.weight, NSLocalizedString(@"г", nil)];
    }
    if(self.position.volume > 0){
        self.weightLabel.text = [NSString stringWithFormat:@"%.0f %@", self.position.volume, NSLocalizedString(@"мл", nil)];
    }
    
    self.energyLabel.text = @"";
    if(self.position.energyAmount > 0){
        self.energyLabel.text = [NSString stringWithFormat:@"%.0f %@", self.position.energyAmount, NSLocalizedString(@"ккал", nil)];
    }
    
    self.priceLabel.text = [NSString stringWithFormat:@"%.0f %@", self.position.price, [Compatibility currencySymbol]];
}

- (CGFloat)moduleViewContentHeight {
    int height = self.frame.size.height - self.titleLabel.frame.size.height - self.descriptionLabel.frame.size.height;
    
    CGSize titleSize = [self.titleLabel.text boundingRectWithSize:CGSizeMake(self.titleLabel.frame.size.width, MAXFLOAT)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName : self.titleLabel.font}
                                                          context:nil].size;
    if (self.titleLabel.text.length == 0){
        titleSize = CGSizeZero;
    }
    
    CGSize descriptionSize = [self.descriptionLabel.text boundingRectWithSize:CGSizeMake(self.descriptionLabel.frame.size.width, MAXFLOAT)
                                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                                   attributes:@{NSFontAttributeName : self.descriptionLabel.font}
                                                                      context:nil].size;
    if (self.descriptionLabel.text.length == 0){
        descriptionSize = CGSizeZero;
    }
    
    height += titleSize.height + descriptionSize.height + 5;
    
    return height;
}

@end
