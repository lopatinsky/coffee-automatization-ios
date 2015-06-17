//
//  DBTimePickerView.h
//  DoubleB
//
//  Created by Ощепков Иван on 17.02.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderManager.h"

@class DBTimePickerView;

typedef NS_ENUM(NSUInteger, DBTimePickerType) {
    DBTimePickerTypeItems = 0,
    DBTimePickerTypeDate,
    DBTimePickerTypeTime,
    DBTimePickerTypeDateTime
};

@protocol DBTimePickerViewDelegate <NSObject>
@optional
- (void)db_timePickerView:(DBTimePickerView *)view didSelectSegmentAtIndex:(NSInteger)index;

- (void)db_timePickerView:(DBTimePickerView *)view didSelectRowAtIndex:(NSInteger)index;
- (void)db_timePickerView:(DBTimePickerView *)view didSelectDate:(NSDate *)date;

- (BOOL)db_shouldHideTimePickerView;
@end

@interface DBTimePickerView : UIView
@property (weak, nonatomic) IBOutlet UIDatePicker *datePickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSegmentedControl;

@property (nonatomic) DBTimePickerType type;
@property (strong, nonatomic) NSDate *minDate;
@property (strong, nonatomic) NSDate *maxDate;


@property (strong, nonatomic) NSArray *segments;
@property (strong, nonatomic) NSArray *items;

@property (nonatomic) NSInteger selectedSegmentIndex;
@property (nonatomic) NSInteger selectedItem;
@property (strong, nonatomic) NSDate *selectedDate;

- (instancetype)initWithDelegate:(id<DBTimePickerViewDelegate>)delegate;

- (void)configure;

- (void)showOnView:(UIView *)view;
- (void)dismiss;

@end
