//
//  DBPaymentCardAdditionModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 18.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBPaymentCardAdditionModuleView.h"

@interface DBPaymentCardAdditionModuleView ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mastercardLogoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *maestroLogoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *visaLogoImageView;

@end

@implementation DBPaymentCardAdditionModuleView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBPaymentCardAdditionModuleView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    _titleLabel.textColor = [UIColor db_defaultColor];
    _titleLabel.text = NSLocalizedString(@"Добавить карту", nil);
}

@end
