//
//  DBNOOrderModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 17/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBNOOrderModuleView.h"
#import "UIView+RoundedCorners.h"
#import "OrderCoordinator.h"

@interface DBNOOrderModuleView ()
@property (weak, nonatomic) IBOutlet UIButton *orderButton;

@end

@implementation DBNOOrderModuleView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBNOOrderModuleView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.orderButton setRoundedCorners];
    [self.orderButton setTitle:NSLocalizedString(@"Заказать", nil) forState:UIControlStateNormal];
    [self.orderButton addTarget:self action:@selector(clickOrderButton) forControlEvents:UIControlEventTouchUpInside];
    
    [[OrderCoordinator sharedInstance] addObserver:self withKeyPaths:@[] selector:@selector(reload)];
    
    [self reload:NO];
}

- (void)dealloc {
    [[OrderCoordinator sharedInstance] removeObserver:self];
}

- (void)reload:(BOOL)animated {
    [super reload:animated];
    
    if (![OrderCoordinator sharedInstance].validOrder) {
        self.orderButton.backgroundColor = [UIColor db_grayColor];
        self.orderButton.alpha = 0.5;
    } else {
        self.orderButton.backgroundColor = [UIColor db_defaultColor];
        self.orderButton.alpha = 1;
    }
}

- (void)clickOrderButton {
    [GANHelper analyzeEvent:@"order_button_click" category:ORDER_SCREEN];
}

@end
