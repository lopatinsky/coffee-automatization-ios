//
//  DBNOWalletModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 16/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBNOWalletModuleView.h"

#import "OrderCoordinator.h"

@interface DBNOWalletModuleView ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *bonusSwitch;
@end

@implementation DBNOWalletModuleView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBNOWalletModuleView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    self.bonusSwitch.onTintColor = [UIColor db_defaultColor];
    
    [self.bonusSwitch addTarget:self action:@selector(bonusSwitchChangedValue:) forControlEvents:UIControlEventValueChanged];
    
    [[OrderCoordinator sharedInstance] addObserver:self withKeyPath:CoordinatorNotificationOrderWalletDiscount selector:@selector(reload)];
    
    [self reload:NO];
}

- (void)dealloc{
    [[OrderCoordinator sharedInstance] removeObserver:self];
}

- (void)reload:(BOOL)animated {
    [super reload:animated];
    
    if([OrderCoordinator sharedInstance].promoManager.walletDiscount > 0){
        self.titleLabel.text = [NSString stringWithFormat:@"%@ %.0f %@", NSLocalizedString(@"Оплатить бонусами", nil), [OrderCoordinator sharedInstance].promoManager.walletDiscount, [Compatibility currencySymbol]];
    }
}

- (void)bonusSwitchChangedValue:(id)sender{
    [OrderCoordinator sharedInstance].promoManager.walletActiveForOrder = self.bonusSwitch.isOn;
}

@end
