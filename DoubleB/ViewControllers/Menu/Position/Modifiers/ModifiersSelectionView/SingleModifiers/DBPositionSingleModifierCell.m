//
//  DBPositionGroupModifierCell.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 03.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBPositionSingleModifierCell.h"
#import "DBMenuPositionModifier.h"


typedef NS_ENUM(NSUInteger, SingleModifierCellState) {
    SingleModifierCellStateEmpty = 0,
    SingleModifierCellStateOpened,
    SingleModifierCellStateClosed
};

@interface DBPositionSingleModifierCell ()
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintPriceViewWidth;
@property (nonatomic) CGFloat initialPriceViewWidth;

@property (weak, nonatomic) IBOutlet UIView *plusView;
@property (weak, nonatomic) IBOutlet UIView *plusViewSeparator;
@property (weak, nonatomic) IBOutlet UIImageView *plusImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintPlusViewWidth;

@property (weak, nonatomic) IBOutlet UIView *minusView;
@property (weak, nonatomic) IBOutlet UIView *minusSeparator;
@property (weak, nonatomic) IBOutlet UIImageView *minusImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintMinusViewWidth;

@property (weak, nonatomic) IBOutlet UIView *countView;
@property (weak, nonatomic) IBOutlet UIView *countSeparator;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintCountViewWidth;

@property (nonatomic) CGFloat initialPlusViewWidth;

@property (strong, nonatomic) DBMenuPositionModifier *modifier;
@property (nonatomic) SingleModifierCellState state;

@property (nonatomic) NSInteger lastModifiedId;

@end

@implementation DBPositionSingleModifierCell

- (void)awakeFromNib {
    self.plusViewSeparator.backgroundColor = [UIColor db_separatorColor];
    self.minusSeparator.backgroundColor = [UIColor db_separatorColor];
    self.countSeparator.backgroundColor = [UIColor db_separatorColor];
    
    self.initialPriceViewWidth = self.constraintPriceViewWidth.constant;
    self.initialPlusViewWidth = self.constraintPlusViewWidth.constant;
    
    self.state = SingleModifierCellStateEmpty;
    
    @weakify(self)
    self.plusView.userInteractionEnabled = YES;
    [self.plusView addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self)
        if(self.modifier.maxAmount > self.modifier.selectedCount){
            self.modifier.selectedCount++;
            
            [self reload];
            [self setState:SingleModifierCellStateOpened animated:YES];
            [self registerTouch];
            
            if([self.delegate respondsToSelector:@selector(db_singleModifierCellDidIncreaseModifierItemCount:)]){
                [self.delegate db_singleModifierCellDidIncreaseModifierItemCount:self.modifier];
            }
        }
    }]];
    
    self.minusView.userInteractionEnabled = YES;
    [self.minusView addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self)
        if(self.modifier.selectedCount > self.modifier.minAmount){
            self.modifier.selectedCount--;
            if(self.modifier.selectedCount < 0) self.modifier.selectedCount = 0;
            
            [self reload];
            if(self.modifier.selectedCount == 0){
                [self setState:SingleModifierCellStateEmpty animated:YES];
            }
            [self registerTouch];
            
            if([self.delegate respondsToSelector:@selector(db_singleModifierCellDidDecreaseModifierItemCount:)]){
                [self.delegate db_singleModifierCellDidDecreaseModifierItemCount:self.modifier];
            }
        }
    }]];
    
    self.countView.userInteractionEnabled = YES;
    [self.countView addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self)
        if(self.state == SingleModifierCellStateClosed){
            [self setState:SingleModifierCellStateOpened animated:YES];
        }
        [self registerTouch];
    }]];
}

- (void)configureWithModifier:(DBMenuPositionModifier *)modifier
                    havePrice:(BOOL)havePrice
                     delegate:(id<DBPositionSingleModifierCellDelegate>)delegate;{
    self.modifier = modifier;
    self.delegate = delegate;
    self.havePrice = havePrice;
    
    if (self.currencyDisplayMode == DBUICurrencyDisplayModeRub) {
        self.priceLabel.text = [NSString stringWithFormat:@"%.0f %@", self.modifier.modifierPrice, [Compatibility currencySymbol]];
    }
    if (self.currencyDisplayMode == DBUICurrencyDisplayModeNone) {
        self.priceLabel.text = [NSString stringWithFormat:@"%.0f", [self.modifier.modifierDictionary[@"points"] floatValue]];
    }
    self.itemTitleLabel.text = self.modifier.modifierName;
    
    [self reload];
    if(self.modifier.selectedCount == 0){
        [self setState:SingleModifierCellStateEmpty animated:NO];
    } else {
        [self setState:SingleModifierCellStateClosed animated:NO];
    }
}

- (void)setState:(SingleModifierCellState)state animated:(BOOL)animated{
    self.state = state;
    
    if(self.state == SingleModifierCellStateEmpty){
        [self hideMinusView:animated];
        [self hideCountView:animated];
        [self showPlusView:animated];
    }
    if(self.state == SingleModifierCellStateClosed){
        [self hideMinusView:animated];
        [self hidePlusView:animated];
        [self showCountView:animated];
    }
    if(self.state == SingleModifierCellStateOpened){
        [self showMinusView:animated];
        [self showPlusView:animated];
        [self showCountView:animated];
    }
}

- (void)setHavePrice:(BOOL)havePrice{
    _havePrice = havePrice;
    if(!havePrice){
        self.constraintPriceViewWidth.constant = 0.f;
    } else {
        self.constraintPriceViewWidth.constant = self.initialPriceViewWidth;
    }
}

- (void)registerTouch{
    NSInteger currentId = self.lastModifiedId + 1;
    self.lastModifiedId = currentId;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(currentId == self.lastModifiedId && self.state == SingleModifierCellStateOpened){
            [self setState:SingleModifierCellStateClosed animated:YES];
        }
    });
}

- (void)reload {
    if(self.modifier.selectedCount == 0){
        [self.plusImageView templateImageWithName:@"modifier_plus_icon.png" tintColor:[UIColor db_grayColor]];
    } else {
        self.plusImageView.image = [UIImage imageNamed:@"modifier_plus_icon.png"];
    }
    
    self.countLabel.text = [NSString stringWithFormat:@"%d", self.modifier.selectedCount];
}

- (void)showPlusView:(BOOL)animated{
    [self setValue:self.initialPlusViewWidth forConstraint:self.constraintPlusViewWidth animated:animated];
}
- (void)showMinusView:(BOOL)animated{
    [self setValue:self.initialPlusViewWidth forConstraint:self.constraintMinusViewWidth animated:animated];
}
- (void)showCountView:(BOOL)animated{
    [self setValue:self.initialPlusViewWidth forConstraint:self.constraintCountViewWidth animated:animated];
}

- (void)hidePlusView:(BOOL)animated{
    [self setValue:0 forConstraint:self.constraintPlusViewWidth animated:animated];
}
- (void)hideMinusView:(BOOL)animated{
    [self setValue:0 forConstraint:self.constraintMinusViewWidth animated:animated];
}
- (void)hideCountView:(BOOL)animated{
    [self setValue:0 forConstraint:self.constraintCountViewWidth animated:animated];
}

- (void)setValue:(CGFloat)value forConstraint:(NSLayoutConstraint *)constraint animated:(BOOL)animated{
    if(animated){
        [UIView animateWithDuration:0.2 animations:^{
            constraint.constant = value;
            [self layoutIfNeeded];
        }];
    } else {
        constraint.constant = value;
        [self layoutIfNeeded];
    }
}

@end
