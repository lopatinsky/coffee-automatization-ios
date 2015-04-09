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

@property (strong, nonatomic) DBMenuPositionModifierItem *item;

@end

@implementation DBPositionGroupModifierItemCell

- (void)awakeFromNib {
    self.selectionView.backgroundColor = [UIColor db_defaultColor];
    
    self.initialPriceViewWidth = self.constraintPriceViewWidth.constant;
    self.initialSelectionViewWidth = self.constraintSelectionViewWidth.constant;
}

- (void)configureWithModifierItem:(DBMenuPositionModifierItem *)item
                        havePrice:(BOOL)havePrice{
    self.item = item;
    self.havePrice = havePrice;
    
    self.titleLabel.text = item.itemName;
    self.priceLabel.text = [NSString stringWithFormat:@"%0.f р.", item.itemPrice];
}

- (void)setHavePrice:(BOOL)havePrice{
    _havePrice = havePrice;
    if(!havePrice){
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
