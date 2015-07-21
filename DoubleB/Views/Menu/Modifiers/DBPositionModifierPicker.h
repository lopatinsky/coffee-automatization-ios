//
//  DBPositionModifierPicker.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 03.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBMenuPosition;
@class DBMenuPositionModifier;
@class DBMenuPositionModifierItem;
@class DBPositionModifierPicker;

typedef NS_ENUM(NSUInteger, DBPositionModifierPickerType) {
    DBPositionModifierPickerTypeGroup = 0,
    DBPositionModifierPickerTypeSingle
};

@protocol DBPositionModifierPickerDelegate <NSObject>
- (void)db_positionModifierPickerDidChangeItemCount:(DBPositionModifierPicker *)picker;
- (void)db_positionModifierPicker:(DBPositionModifierPicker *)picker didSelectNewItem:(DBMenuPositionModifierItem *)item;
@end

@interface DBPositionModifierPicker : UIView
@property(nonatomic, readonly) DBPositionModifierPickerType type;
@property (nonatomic, strong) DBMenuPosition *position;
@property(weak, nonatomic) id<DBPositionModifierPickerDelegate> delegate;

- (void)configureGroupModifierAtIndexPath:(NSIndexPath *)indexPath;
- (void)configureSingleModifiers;

- (void)showOnView:(UIView *)parentView;
- (void)hide;

@end
