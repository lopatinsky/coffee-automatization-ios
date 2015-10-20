//
//  DBNOItemAdditionModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 19/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBNOItemAdditionModuleView.h"
#import "DBBonusPositionsViewController.h";

#import "OrderCoordinator.h"

@interface DBNOItemAdditionModuleView ()
@property (weak, nonatomic) IBOutlet UIView *positionAdditionView;
@property (weak, nonatomic) UILabel *positionAdditionLabel;

@property (weak, nonatomic) IBOutlet UIView *giftAdditionView;
@property (weak, nonatomic) IBOutlet UIImageView *giftAdditionImageView;
@property (weak, nonatomic) IBOutlet UILabel *giftAdditionBalanceLabel;
@property (weak, nonatomic) IBOutlet UIView *giftAdditionSeparatorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintGiftAdditionViewWidth;
@property (nonatomic) double initialGiftAdditionViewWidth;
@end

@implementation DBNOItemAdditionModuleView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBNOItemAdditionModuleView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.positionAdditionLabel = (UILabel *)[self.positionAdditionView viewWithTag:10];
    
    self.positionAdditionLabel.textColor = [UIColor db_defaultColor];
    
    [self.giftAdditionImageView templateImageWithName:@"gift_icon.png"];
    
    self.initialGiftAdditionViewWidth = self.constraintGiftAdditionViewWidth.constant;
}

- (void)reload:(BOOL)animated {
    [super reload:animated];
    
    [self reloadAdditionButton:animated];
    [self reloadGiftButton:animated];
}

- (void)reloadAdditionButton:(BOOL)animated {
    NSString *text = [OrderCoordinator sharedInstance].itemsManager.totalCount > 0 ? NSLocalizedString(@"Дополнить", nil) : NSLocalizedString(@"Меню", nil);
    self.positionAdditionLabel.text = text;
    
    // Fucking code for Elephant
    if([[DBCompanyInfo sharedInstance].bundleName.lowercaseString isEqualToString:@"elephantboutique"]){
        self.positionAdditionLabel.textColor = [UIColor colorWithRed:216./255 green:134./255 blue:126./255 alpha:1.0];
        self.positionAdditionLabel.text = @"Выбрать напиток";
    }
}

- (void)reloadGiftButton:(BOOL)animated {
    void (^animationBlock)(BOOL) = ^void(BOOL showBonusPositionsView){
        if(showBonusPositionsView){
            self.constraintGiftAdditionViewWidth.constant = self.initialGiftAdditionViewWidth;
        } else {
            self.constraintGiftAdditionViewWidth.constant = 0;
        }
        [self layoutIfNeeded];
    };
    
    int totalPoints = [OrderCoordinator sharedInstance].promoManager.bonusPointsBalance - [OrderCoordinator sharedInstance].bonusItemsManager.totalPrice;
    NSString *pointsString = [NSString db_localizedFormOfWordBall:totalPoints];
    self.giftAdditionBalanceLabel.text = [NSString stringWithFormat:@"%ld %@", (long)totalPoints, pointsString];
    
    BOOL bonusViewVisible = [OrderCoordinator sharedInstance].promoManager.bonusPositionsAvailable && totalPoints > 0;
    if(animated){
        [UIView animateWithDuration:.2f animations:^{
            animationBlock(bonusViewVisible);
        }];
    } else {
        animationBlock(bonusViewVisible);
    }
}

- (void)touchAtLocation:(CGPoint)location {
    if (CGRectContainsPoint(self.giftAdditionView.frame, location)){
        DBBonusPositionsViewController *bonusPositionsVC = [DBBonusPositionsViewController new];
        bonusPositionsVC.hidesBottomBarWhenPushed = YES;
        [self.ownerViewController.navigationController pushViewController:bonusPositionsVC animated:YES];
    } else {
        [GANHelper analyzeEvent:@"plus_click" category:ORDER_SCREEN];
        
        UIViewController<MenuListViewControllerProtocol> *menuVC = [[[ApplicationManager sharedInstance] rootMenuViewController] createViewController];
        menuVC.hidesBottomBarWhenPushed = YES;
        [self.ownerViewController.navigationController pushViewController:menuVC animated:YES];
    }
}

@end
