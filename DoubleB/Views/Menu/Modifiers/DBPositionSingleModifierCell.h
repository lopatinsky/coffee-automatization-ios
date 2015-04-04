//
//  DBPositionGroupModifierCell.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 03.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBMenuPositionModifier;

@interface DBPositionSingleModifierCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemTitleLabel;

- (void)configureWithModifier:(DBMenuPositionModifier *)modifier;

@end
