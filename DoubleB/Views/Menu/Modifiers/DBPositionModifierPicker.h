//
//  DBPositionModifierPicker.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 03.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBMenuPositionModifier;

typedef NS_ENUM(NSUInteger, DBPositionModifierPickerType) {
    DBPositionModifierPickerTypeGroup = 0,
    DBPositionModifierPickerTypeSingle
};


@interface DBPositionModifierPicker : UIView
@property(nonatomic, readonly) DBPositionModifierPickerType type;

- (void)configureWithGroupModifier:(DBMenuPositionModifier *)modifier;
- (void)configureWithSingleModifiers:(NSArray *)modifiers;

- (void)showOnView:(UIView *)parentView;
- (void)hide;

@end
