//
//  DBPersonalWalletView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 03.06.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBPersonalWalletView.h"
#import "OrderCoordinator.h"

@interface DBPersonalWalletView ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) UIImageView *overlayView;

@end

@implementation DBPersonalWalletView

+ (DBPersonalWalletView *)create{
    DBPersonalWalletView *view = [[[NSBundle mainBundle] loadNibNamed:@"DBPersonalWalletView" owner:self options:nil] firstObject];
    
    return view;
}

- (void)awakeFromNib{
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 5.f;
    self.layer.masksToBounds = YES;
    
    self.balanceLabel.textColor = [UIColor db_defaultColor];
    
    self.activityIndicator.hidesWhenStopped = YES;
    
    [self reloadAppearance];
}

- (void)reload{
    [self.activityIndicator startAnimating];
    self.balanceLabel.hidden = YES;
    
    [[OrderCoordinator sharedInstance].promoManager updatePersonalWalletBalance:^(double balance) {
        [self.activityIndicator stopAnimating];
        self.balanceLabel.hidden = NO;
        
        [self reloadAppearance];
        
        if([self.delegate respondsToSelector:@selector(db_personalWalletView:didUpdateBalance:)]){
            [self.delegate db_personalWalletView:self didUpdateBalance:balance];
        }
    }];
}

- (void)reloadAppearance{
    self.balanceLabel.text = [NSString stringWithFormat:@"%.1f", [OrderCoordinator sharedInstance].promoManager.walletBalance];
    
    if([OrderCoordinator sharedInstance].promoManager.walletTextDescription.length > 0){
        self.titleLabel.text = [OrderCoordinator sharedInstance].promoManager.walletTextDescription;
    } else {
        self.titleLabel.text = @"Баланс вашего персонального счета";
    }
}

- (void)db_popupContentReload {
    [self reload];
}

- (CGFloat)db_popupContentContentHeight {
    return self.frame.size.height;
}

#pragma mark - DBSettingsProtocol

+ (id<DBSettingsItemProtocol>)settingsItem {
    DBSettingsItem *settingsItem = [DBSettingsItem new];
    settingsItem.name = @"personalWalletVC";
    settingsItem.iconName = @"wallet_icon_active";
    
    NSString *profileText = @"";
    if ([[[OrderCoordinator sharedInstance] promoManager] walletBalance] > 0) {
        profileText = [NSString stringWithFormat:@"%@: %.1f", NSLocalizedString(@"Личный счет", nil), [OrderCoordinator sharedInstance].promoManager.walletBalance];
    } else {
        profileText = NSLocalizedString(@"Личный счет", nil);
    }
    settingsItem.title = profileText;
    
    settingsItem.eventLabel = @"personal_wallet_click";
    
    settingsItem.block = ^(UIViewController *vc){
        [DBPopupViewController presentView:[DBPersonalWalletView create] inContainer:vc mode:DBPopupVCAppearanceModeHeader];
    };
    
    return settingsItem;
}

@end
