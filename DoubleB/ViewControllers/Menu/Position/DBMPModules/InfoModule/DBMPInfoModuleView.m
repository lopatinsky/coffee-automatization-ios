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
    return 100.f;
}

@end
