//
//  DBNewOrderItemAdditionView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 20.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBNewOrderItemAdditionView.h"
#import "OrderCoordinator.h"

@interface DBNewOrderItemAdditionView ()
@property (weak, nonatomic) IBOutlet UIView *positionAdditionView;
@property (weak, nonatomic) UILabel *positionAdditionLabel;

@property (weak, nonatomic) IBOutlet UIView *giftAdditionView;
@property (weak, nonatomic) IBOutlet UIImageView *giftAdditionImageView;
@property (weak, nonatomic) IBOutlet UILabel *giftAdditionBalanceLabel;
@property (weak, nonatomic) IBOutlet UIView *giftAdditionSeparatorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintGiftAdditionViewWidth;
@property (nonatomic) double initialGiftAdditionViewWidth;
@end

@implementation DBNewOrderItemAdditionView

- (void)awakeFromNib{
    self.positionAdditionLabel = (UILabel *)[self.positionAdditionView viewWithTag:10];
    
    self.positionAdditionLabel.textColor = [UIColor db_defaultColor];
    
    [self.giftAdditionImageView templateImageWithName:@"gift_icon.png"];
    
    self.initialGiftAdditionViewWidth = self.constraintGiftAdditionViewWidth.constant;
    
    @weakify(self)
    self.positionAdditionView.userInteractionEnabled = YES;
    [self.positionAdditionView addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self);
        if([self.delegate respondsToSelector:@selector(db_newOrderItemAdditionViewDidSelectPositions:)]){
            [self.delegate db_newOrderItemAdditionViewDidSelectPositions:self];
        }
    }]];
    
    self.giftAdditionView.userInteractionEnabled = YES;
    [self.giftAdditionView addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self);
        if([self.delegate respondsToSelector:@selector(db_newOrderItemAdditionViewDidSelectBonusPositions:)]){
            [self.delegate db_newOrderItemAdditionViewDidSelectBonusPositions:self];
        }
    }]];
    
    [self reload];
    self.showBonusPositionsView = NO;
}

- (void)reload{
    NSString *text = [OrderCoordinator sharedInstance].itemsManager.totalCount > 0 ? NSLocalizedString(@"Дополнить", nil) : NSLocalizedString(@"Меню", nil);
    self.positionAdditionLabel.text = text;
    
    int totalPoints = [OrderCoordinator sharedInstance].promoManager.bonusPointsBalance - [OrderCoordinator sharedInstance].bonusItemsManager.totalPrice;
    NSString *pointsString = [NSString db_localizedFormOfWordBall:totalPoints];
    self.giftAdditionBalanceLabel.text = [NSString stringWithFormat:@"%ld %@", (long)totalPoints, pointsString];
    
    BOOL bonusViewVisible = [OrderCoordinator sharedInstance].promoManager.bonusPositionsAvailable && totalPoints > 0;
    [self showBonusPositionsView:bonusViewVisible animated:YES];
    
    // Fucking code for Elephant
    if([[DBCompanyInfo sharedInstance].bundleName.lowercaseString isEqualToString:@"elephantboutique"]){
        self.positionAdditionLabel.textColor = [UIColor colorWithRed:216./255 green:134./255 blue:126./255 alpha:1.0];
        self.positionAdditionLabel.text = @"Выбрать напиток";
    }
}

- (void)setShowBonusPositionsView:(BOOL)showBonusPositionsView{
    [self showBonusPositionsView:showBonusPositionsView animated:NO];
}

- (void)showBonusPositionsView:(BOOL)showBonusPositionsView animated:(BOOL)animated{
    _showBonusPositionsView = showBonusPositionsView;
    
    void (^animationBlock)(BOOL) = ^void(BOOL showBonusPositionsView){
        if(showBonusPositionsView){
            self.constraintGiftAdditionViewWidth.constant = self.initialGiftAdditionViewWidth;
        } else {
            self.constraintGiftAdditionViewWidth.constant = 0;
        }
        [self layoutIfNeeded];
    };
    
    if(animated){
        [UIView animateWithDuration:.2f animations:^{
            animationBlock(showBonusPositionsView);
        }];
    } else {
        animationBlock(showBonusPositionsView);
    }
}

@end
