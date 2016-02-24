//
//  IHPickerView.h
//  IIkoHackathon
//
//  Created by Ivan Oschepkov on 13/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBPopupComponent.h"

typedef NS_ENUM(NSInteger, DBPickerViewMode) {
    DBPickerViewModeItems = 0,
    DBPickerViewModeDate
};

@class DBPickerView;
@protocol DBPickerViewDelegate <NSObject>
@optional
- (void)db_pickerView:(DBPickerView *)view didSelectRow:(NSString *)row;
- (void)db_pickerView:(DBPickerView *)view didSelectRowAtIndex:(NSUInteger)rowIndex;

- (void)db_pickerView:(DBPickerView *)view didSelectDate:(NSDate *)date;

@end

@interface DBPickerView : DBPopupComponent
@property (nonatomic) DBPickerViewMode mode;
@property (weak, nonatomic) id<DBPickerViewDelegate, DBPopupComponentDelegate> pickerDelegate;
@property (strong, nonatomic) NSString *title;

+ (DBPickerView *)create:(DBPickerViewMode)mode;

- (void)configureWithItems:(NSArray *)items;
@property (nonatomic) NSUInteger selectedIndex;

@property (strong, nonatomic) NSDate *selectedDate;
@property (strong, nonatomic) NSDate *minDate;
@property (strong, nonatomic) NSDate *maxDate;

@end
