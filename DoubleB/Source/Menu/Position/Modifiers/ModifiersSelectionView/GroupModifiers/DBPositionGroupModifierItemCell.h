//
//  DBPositionGroupModifierItemCell.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 06.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBMenuPosition.h"

@class DBMenuPositionModifierItem;

@interface DBPositionGroupModifierItemCell : UITableViewCell
@property(nonatomic) DBUICurrencyDisplayMode currencyDisplayMode;

@property (nonatomic, strong, readonly) DBMenuPositionModifierItem *item;
@property (nonatomic) BOOL havePrice;
@property (nonatomic, readonly) BOOL stateSelected;

- (void)configureWithModifierItem:(DBMenuPositionModifierItem *)item
                        havePrice:(BOOL)havePrice;
- (void)select:(BOOL)selected animated:(BOOL)animated;

@end
