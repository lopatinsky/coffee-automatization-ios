//
//  DBPositionGroupModifierCell.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 03.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBMenuPosition.h"

@class DBMenuPositionModifier;
@class DBPositionSingleModifierCell;

@protocol DBPositionSingleModifierCellDelegate <NSObject>
- (void)db_singleModifierCellDidIncreaseModifierItemCount:(DBMenuPositionModifier *)modifier;
- (void)db_singleModifierCellDidDecreaseModifierItemCount:(DBMenuPositionModifier *)modifier;
@end

@interface DBPositionSingleModifierCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *itemTitleLabel;

@property(nonatomic) DBUICurrencyDisplayMode currencyDisplayMode;

@property (weak, nonatomic) id<DBPositionSingleModifierCellDelegate> delegate;
@property (nonatomic) BOOL havePrice;

- (void)configureWithModifier:(DBMenuPositionModifier *)modifier
                    havePrice:(BOOL)havePrice
                     delegate:(id<DBPositionSingleModifierCellDelegate>)delegate;

@end
