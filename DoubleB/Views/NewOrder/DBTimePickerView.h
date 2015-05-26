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

@protocol DBTimePickerViewDelegate <NSObject>
- (NSInteger)db_numberOfSegmentsInTimePickerView:(DBTimePickerView *)view;
- (NSString *)db_timePickerView:(DBTimePickerView *)view titleForSegmentAtIndex:(NSUInteger)index;

- (void)db_timePickerView:(DBTimePickerView *)view didSelectSegmentAtIndex:(NSInteger)index;

- (NSInteger)db_numberOfRowsInTimePickerView:(DBTimePickerView *)view;
- (NSString *)db_timePickerView:(DBTimePickerView *)view titleForRowAtIndex:(NSUInteger)index;

- (void)db_timePickerViewDidSelectRowAtIndex:(NSInteger)index;

- (BOOL)db_shouldHideTimePickerView;
@end

@interface DBTimePickerView : UIView
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSegmentedControl;

@property (nonatomic) NSInteger selectedSegmentIndex;
@property (nonatomic) NSInteger selectedRow;

- (instancetype)initWithDelegate:(id<DBTimePickerViewDelegate>)delegate;

- (void)showOnView:(UIView *)view;
- (void)dismiss;

@end
