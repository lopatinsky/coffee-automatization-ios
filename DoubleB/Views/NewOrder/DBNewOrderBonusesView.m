//
//  DBNewOrderBonusesView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 28.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBNewOrderBonusesView.h"
#import "DBPromoManager.h"
#import "Compatibility.h"

@interface DBNewOrderBonusesView ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeight;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *bonusSwitch;

@property (nonatomic) double initialHeight;

@end

@implementation DBNewOrderBonusesView

- (void)awakeFromNib{
    self.bonusSwitch.onTintColor = [UIColor db_defaultColor];
    self.initialHeight = self.constraintHeight.constant;
    
    [self.bonusSwitch addTarget:self action:@selector(bonusSwitchChangedValue:) forControlEvents:UIControlEventValueChanged];
    
    [[DBPromoManager sharedManager] addObserver:self
                                     forKeyPath:@"walletPointsAvailableForOrder"
                                        options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                                        context:nil];
}

- (void)dealloc{
    [[DBPromoManager sharedManager] removeObserver:self forKeyPath:@"walletPointsAvailableForOrder"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context{
    if([keyPath isEqualToString:@"walletPointsAvailableForOrder"]){
        [self reloadTitle];
    }
}

- (void)reloadTitle{
    if([DBPromoManager sharedManager].walletPointsAvailableForOrder > 0){
        self.titleLabel.text = [NSString stringWithFormat:@"Оплатить бонусами %.0f %@", [DBPromoManager sharedManager].walletPointsAvailableForOrder, [Compatibility currencySymbol]];
    }
}

- (void)bonusSwitchChangedValue:(id)sender{
    if([self.delegate respondsToSelector:@selector(db_newOrderBonusesView:didSelectBonuses:)]){
        [self.delegate db_newOrderBonusesView:self didSelectBonuses:self.bonusSwitch.isOn];
    }
}

- (void)setTitleText:(NSString *)titleText{
    self.titleLabel.text = titleText;
}

- (void)setBonusSwitchActive:(BOOL)bonusSwitchActive{
    self.bonusSwitch.on = bonusSwitchActive;
}

- (void)show:(BOOL)animated completion:(void(^)())completion{
    [self animateHeight:animated animation:^{
        self.constraintHeight.constant = self.initialHeight;
        [self layoutIfNeeded];
    } completion:completion];
}

- (void)hide:(BOOL)animated completion:(void(^)())completion{
    [self animateHeight:animated animation:^{
        self.constraintHeight.constant = 0;
        [self layoutIfNeeded];
    } completion:completion];
}

- (void)animateHeight:(BOOL)animated
            animation:(void(^)())animation
           completion:(void(^)())completion{
    void(^completionBlock)(BOOL) = ^void(BOOL finished){
        if(completion)
            completion();
    };
    
    if(animated){
        [UIView animateWithDuration:0.2 animations:animation completion:completionBlock];
    } else {
        animation();
        completionBlock(YES);
    }
}

@end
