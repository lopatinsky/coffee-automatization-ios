//
//  DBCategoryPicker.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 02.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBPopupComponent.h"

@class DBCategoryPicker;
@class DBMenuCategory;

@protocol DBCategoryPickerDelegate <NSObject>
- (void)db_categoryPicker:(DBCategoryPicker *)picker didSelectCategory:(DBMenuCategory *)category;

@end

@interface DBCategoryPicker : DBPopupComponent
@property (weak, nonatomic) id<DBCategoryPickerDelegate> pickerDelegate;

- (void)configureWithCurrentCategory:(DBMenuCategory *)category categories:(NSArray *)categories;
@end
