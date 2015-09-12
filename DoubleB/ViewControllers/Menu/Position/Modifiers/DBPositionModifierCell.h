//
//  DBPositionModifierCell.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 03.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBMenuPositionModifier;

@interface DBPositionModifierCell : UITableViewCell

- (void)configureWithGroupModifier:(DBMenuPositionModifier *)modifier;
- (void)configureWithSingleModifiers:(NSArray *)singleModifiers;

@end
