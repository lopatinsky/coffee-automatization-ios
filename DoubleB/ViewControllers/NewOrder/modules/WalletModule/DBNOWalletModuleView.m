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

+ (NSString *)xibName {
    return @"DBNOWalletModuleView";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.bonusSwitch.onTintColor = [UIColor db_defaultColor];
    
    [self.bonusSwitch addTarget:self action:@selector(bonusSwitchChangedValue:) forControlEvents:UIControlEventValueChanged];
    
    [[OrderCoordinator sharedInstance] addObserver:self withKeyPath:CoordinatorNotificationOrderWalletDiscount selector:@selector(reload)];
}

- (void)viewWillAppearOnVC {
    self.bonusSwitch.on = [OrderCoordinator sharedInstance].promoManager.walletActiveForOrder;
}

- (void)dealloc{
    [[OrderCoordinator sharedInstance] removeObserver:self];
}

- (void)reload:(BOOL)animated {
    [super reload:animated];
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@ %.0f %@", NSLocalizedString(@"Оплатить бонусами", nil), [OrderCoordinator sharedInstance].promoManager.walletDiscount, [Compatibility currencySymbol]];
}

- (CGFloat)moduleViewContentHeight {
    if([OrderCoordinator sharedInstance].promoManager.walletDiscount > 0){
        return 40;
    } else {
        return 0;
    }
}

- (void)bonusSwitchChangedValue:(id)sender{
    [OrderCoordinator sharedInstance].promoManager.walletActiveForOrder = self.bonusSwitch.isOn;
}

@end
