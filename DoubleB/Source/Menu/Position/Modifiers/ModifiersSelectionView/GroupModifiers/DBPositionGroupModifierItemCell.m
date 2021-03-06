//
//  DBPositionGroupModifierItemCell.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 06.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBPositionGroupModifierItemCell.h"
#import "DBMenuPositionModifierItem.h"

@interface DBPositionGroupModifierItemCell ()
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintPriceViewWidth;
@property (nonatomic) CGFloat initialPriceViewWidth;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIView *selectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintSelectionViewWidth;
@property (nonatomic) CGFloat initialSelectionViewWidth;

@end

@implementation DBPositionGroupModifierItemCell

- (void)awakeFromNib {
    self.selectionView.backgroundColor = [UIColor db_defaultColor];
    
    self.initialPriceViewWidth = self.constraintPriceViewWidth.constant;
    self.initialSelectionViewWidth = self.constraintSelectionViewWidth.constant;
}

- (void)configureWithModifierItem:(DBMenuPositionModifierItem *)item
                        havePrice:(BOOL)havePrice {
    _item = item;
    self.havePrice = havePrice;
    
    if (item) {
        self.titleLabel.text = item.itemName;
        if (self.currencyDisplayMode == DBUICurrencyDisplayModeRub) {
            if (item.itemPrice > 0) {
                self.priceLabel.text = [NSString stringWithFormat:@"+%0.f %@", item.itemPrice, [Compatibility currencySymbol]];
            } else {
                self.priceLabel.text = @"";
                self.constraintPriceViewWidth.constant = 0.f;
            }
        }
        if (self.currencyDisplayMode == DBUICurrencyDisplayModeNone) {
            if ([item.itemDictionary[@"points"] floatValue] > 0) {
                self.priceLabel.text = [NSString stringWithFormat:@"+%0.f", [item.itemDictionary[@"points"] floatValue]];
            } else {
                self.priceLabel.text = @"";
                self.constraintPriceViewWidth.constant = 0.f;
            }
        }
    } else {
        self.titleLabel.text = NSLocalizedString(@"Не выбирать ничего", nil);
        self.priceLabel.text = @"";
    }
}

- (void)setHavePrice:(BOOL)havePrice{
    _havePrice = havePrice;
    if (!havePrice) {
        self.constraintPriceViewWidth.constant = 0.f;
    } else {
        self.constraintPriceViewWidth.constant = self.initialPriceViewWidth;
    }
}

- (void)select:(BOOL)selected animated:(BOOL)animated;{
    _stateSelected = selected;
    if(animated){
        [UIView animateWithDuration:0.2 animations:^{
            self.constraintSelectionViewWidth.constant = selected ? self.initialSelectionViewWidth : 0;
            [self layoutIfNeeded];
        }];
    } else {
        self.constraintSelectionViewWidth.constant = selected ? self.initialSelectionViewWidth : 0;
    }
}

@end
