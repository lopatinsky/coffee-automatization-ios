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
    DBTimePickerTypeDateTime,
    DBTimePickerTypeTime,
    DBTimePickerTypeDateAndItems,
    DBTimePickerTypeDual
};

@protocol DBTimePickerViewDelegate <NSObject>
@optional
- (void)db_timePickerView:(DBTimePickerView *)view didSelectRowAtIndex:(NSInteger)index;
- (void)db_timePickerView:(DBTimePickerView *)view didSelectDate:(NSDate *)date;

- (NSInteger)db_timePickerView:(DBTimePickerType *)view selectedRowForComponent:(NSInteger)selectedRow;

- (BOOL)db_shouldHideTimePickerView;
- (void)db_updateDualMode:(BOOL)isSlots;
@end

@interface DBTimePickerView : UIView
@property (weak, nonatomic) IBOutlet UIDatePicker *datePickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentController;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timePickerTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *datePickerTopConstraint;

@property (nonatomic) DBTimePickerType type;
@property (strong, nonatomic) NSDate *minDate;
@property (strong, nonatomic) NSDate *maxDate;

@property (strong, nonatomic) NSArray *items;

@property (nonatomic) NSInteger selectedItem;
@property (strong, nonatomic) NSDate *selectedDate;

- (instancetype)initWithDelegate:(id<DBTimePickerViewDelegate>)delegate;

- (void)configure;

- (void)showOnView:(UIView *)view;
- (void)dismiss;

@end
