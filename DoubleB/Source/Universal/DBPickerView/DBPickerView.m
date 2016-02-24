//
//  IHPickerView.m
//  IIkoHackathon
//
//  Created by Ivan Oschepkov on 13/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBPickerView.h"

@interface DBPickerView ()<UIPickerViewDataSource, UIPickerViewDelegate>
@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) NSArray *items;
@end

@implementation DBPickerView

+ (DBPickerView *)create:(DBPickerViewMode)mode {
    DBPickerView *view = [[[NSBundle mainBundle] loadNibNamed:@"DBPickerView" owner:self options:nil] firstObject];
    
    view.mode = mode;
    [view commonInit];
    
    return view;
}

- (void)commonInit {
    if (_mode == DBPickerViewModeItems) {
        self.pickerView.hidden = NO;
        self.datePicker.hidden = YES;
        
        self.pickerView.dataSource = self;
        self.pickerView.delegate = self;
    }
    
    if (_mode == DBPickerViewModeDate) {
        self.pickerView.hidden = YES;
        self.datePicker.hidden = NO;
        
        [self.datePicker setDatePickerMode:UIDatePickerModeDate];
        [self.datePicker addTarget:self action:@selector(datePickerValueChanged) forControlEvents:UIControlEventValueChanged];
    }
    
    self.titleLabel.textColor = [UIColor blackColor];
    [self.doneButton setTitleColor:[UIColor db_defaultColor] forState:UIControlStateNormal];
}

- (void)setPickerDelegate:(id<DBPickerViewDelegate,DBPopupComponentDelegate>)pickerDelegate {
    _pickerDelegate = pickerDelegate;
    self.delegate = pickerDelegate;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (void)notifyDelegate {
    if (_mode == DBPickerViewModeItems) {
        if ([self.pickerDelegate respondsToSelector:@selector(db_pickerView:didSelectRow:)]) {
            [self.pickerDelegate db_pickerView:self didSelectRow:_items[[self.pickerView selectedRowInComponent:0]]];
        }
        
        if ([self.pickerDelegate respondsToSelector:@selector(db_pickerView:didSelectRowAtIndex:)]) {
            [self.pickerDelegate db_pickerView:self didSelectRowAtIndex:[self.pickerView selectedRowInComponent:0]];
        }
    }
    
    if (_mode == DBPickerViewModeDate) {
        if ([self.pickerDelegate respondsToSelector:@selector(db_pickerView:didSelectDate:)]) {
            [self.pickerDelegate db_pickerView:self didSelectDate:self.datePicker.date];
        }
    }
}

- (IBAction)doneButtonClick:(id)sender {
    [self notifyDelegate];
    [self hide];
}

#pragma mark - Items mode

- (void)configureWithItems:(NSArray *)items {
    _items = items;
    
    [self.pickerView reloadAllComponents];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    
    if (_selectedIndex < [self.pickerView numberOfRowsInComponent:0]) {
        [self.pickerView selectRow:_selectedIndex inComponent:0 animated:NO];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [_items count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _items[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _selectedIndex = row;
    [self notifyDelegate];
}

#pragma mark - Date mode

- (void)setMinDate:(NSDate *)minDate {
    _minDate = minDate;
    self.datePicker.minimumDate = minDate;
}

- (void)setMaxDate:(NSDate *)maxDate {
    _maxDate = maxDate;
    self.datePicker.maximumDate = maxDate;
}

- (void)setSelectedDate:(NSDate *)selectedDate {
    if (selectedDate) {
        self.datePicker.date = selectedDate;
        _selectedDate = self.datePicker.date;
    }
}

- (void)datePickerValueChanged {
    _selectedDate = self.datePicker.date;
}

@end
