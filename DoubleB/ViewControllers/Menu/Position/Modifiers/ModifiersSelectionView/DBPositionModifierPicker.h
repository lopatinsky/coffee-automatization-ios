//
//  DBPositionModifierPicker.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 03.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBPopupComponent.h"

@class DBMenuPosition;
@class DBMenuPositionModifier;
@class DBMenuPositionModifierItem;
@class DBPositionModifierPicker;

typedef NS_ENUM(NSUInteger, DBPositionModifierPickerType) {
    DBPositionModifierPickerTypeGroup = 0,
    DBPositionModifierPickerTypeSingle
};

typedef NS_ENUM(NSUInteger, DBPositionModifierPickerDisplayType) {
    DBPositionModifierPickerDisplayTypeModal = 0,
    DBPositionModifierPickerDisplayTypePushed
};

@protocol DBPositionModifierPickerDelegate <NSObject>
- (void)db_positionModifierPickerDidChangeItemCount:(DBPositionModifierPicker *)picker;
- (void)db_positionModifierPicker:(DBPositionModifierPicker *)picker didSelectNewItem:(DBMenuPositionModifierItem *)item;
@end

@interface DBPositionModifierPicker : DBPopupComponent
@property(nonatomic, readonly) DBPositionModifierPickerType type;
@property(nonatomic) DBUICurrencyDisplayMode currencyDisplayMode;

// TODO: rename it?
@property(weak, nonatomic) id<DBPositionModifierPickerDelegate> modifierDelegate;

- (void)configureWithGroupModifier:(DBMenuPositionModifier *)modifier;
- (void)configureWithSingleModifiers:(NSArray *)modifiers;

@end
