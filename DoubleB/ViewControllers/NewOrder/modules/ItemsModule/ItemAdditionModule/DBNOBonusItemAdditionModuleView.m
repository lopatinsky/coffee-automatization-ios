//
//  DBNOItemAdditionModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 19/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBNOBonusItemAdditionModuleView.h"
#import "DBBonusPositionsViewController.h"

#import "OrderCoordinator.h"

@interface DBNOBonusItemAdditionModuleView ()
@property (weak, nonatomic) IBOutlet UIView *giftAdditionView;
@property (weak, nonatomic) IBOutlet UIImageView *giftAdditionImageView;
@property (weak, nonatomic) IBOutlet UILabel *giftAdditionBalanceLabel;
@property (weak, nonatomic) IBOutlet UIView *giftAdditionSeparatorView;

@property (nonatomic) NSInteger initialHeight;
@end

@implementation DBNOBonusItemAdditionModuleView

+ (NSString *)xibName {
    return @"DBNOBonusItemAdditionModuleView";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.initialHeight = self.frame.size.height;
    
    [self.giftAdditionImageView templateImageWithName:@"gift_icon.png"];
    
    [[OrderCoordinator sharedInstance] addObserver:self withKeyPaths:@[CoordinatorNotificationPromoUpdated,CoordinatorNotificationBonusItemsTotalCount] selector:@selector(reload)];
}

- (void)dealloc {
    [[OrderCoordinator sharedInstance] removeObserver:self];
}

- (void)reload:(BOOL)animated {
    [super reload:animated];
    
    [self reloadGiftButton:animated];
}

- (void)reloadGiftButton:(BOOL)animated {
    int totalPoints = [OrderCoordinator sharedInstance].promoManager.bonusPointsBalance - [OrderCoordinator sharedInstance].bonusItemsManager.totalPrice;
    NSString *pointsString = [NSString db_localizedFormOfWordBall:totalPoints];
    self.giftAdditionBalanceLabel.text = [NSString stringWithFormat:@"%ld %@", (long)totalPoints, pointsString];
}

- (void)touchAtLocation:(CGPoint)location {
    DBBonusPositionsViewController *bonusPositionsVC = [DBBonusPositionsViewController new];
    bonusPositionsVC.hidesBottomBarWhenPushed = YES;
    [self.ownerViewController.navigationController pushViewController:bonusPositionsVC animated:YES];
}

- (CGFloat)moduleViewContentHeight {
    int totalPoints = [OrderCoordinator sharedInstance].promoManager.bonusPointsBalance - [OrderCoordinator sharedInstance].bonusItemsManager.totalPrice;
    BOOL bonusViewVisible = [OrderCoordinator sharedInstance].promoManager.bonusPositionsAvailable && totalPoints > 0;
    
    return bonusViewVisible ? self.initialHeight : 0;
}

@end
