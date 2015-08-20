//
//  DBPaymentCardAdditionModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 18.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBPaymentCardAdditionModuleView.h"

#import "UIViewController+DBCardManagement.h"
#import "UIGestureRecognizer+BlocksKit.h"

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
    
    @weakify(self)
    [self addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self)
        [self.ownerViewController db_cardManagementBindNewCardOnScreen:self.analyticsCategory callback:nil];
        
        [GANHelper analyzeEvent:@"add_card_pressed" category:PAYMENT_SCREEN];
    }]];
}


@end
