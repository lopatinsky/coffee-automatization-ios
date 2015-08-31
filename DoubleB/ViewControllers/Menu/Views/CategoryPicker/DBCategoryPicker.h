//
//  DBCategoryPicker.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 02.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBCategoryPicker;
@class DBMenuCategory;

@protocol DBCategoryPickerDelegate <NSObject>
- (void)db_categoryPicker:(DBCategoryPicker *)picker didSelectCategory:(DBMenuCategory *)category;

@end

@interface DBCategoryPicker : UIView
@property (nonatomic, readonly) BOOL isOpened;
@property (strong, nonatomic, readonly) UIView *owner;
@property (weak, nonatomic) id<DBCategoryPickerDelegate> delegate;

- (void)configureWithCurrentCategory:(DBMenuCategory *)category categories:(NSArray *)categories;

- (void)openedOnView:(UIView *)view;
- (void)closed;
@end
