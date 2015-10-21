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
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) NSArray *items;
@end

@implementation DBPickerView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBPickerView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    
    self.titleLabel.textColor = [UIColor blackColor];
    [self.doneButton setTitleColor:[UIColor db_defaultColor] forState:UIControlStateNormal];
}

- (void)setPickerDelegate:(id<DBPickerViewDelegate,DBPopupViewComponentDelegate>)pickerDelegate {
    _pickerDelegate = pickerDelegate;
    self.delegate = pickerDelegate;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

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

- (void)notifyDelegate {
    if ([self.pickerDelegate respondsToSelector:@selector(db_pickerView:didSelectRow:)]) {
        [self.pickerDelegate db_pickerView:self didSelectRow:_items[[self.pickerView selectedRowInComponent:0]]];
    }
    
    if ([self.pickerDelegate respondsToSelector:@selector(db_pickerView:didSelectRowAtIndex:)]) {
        [self.pickerDelegate db_pickerView:self didSelectRowAtIndex:[self.pickerView selectedRowInComponent:0]];
    }
}

- (IBAction)doneButtonClick:(id)sender {
    [self notifyDelegate];
    [self hide];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [_items count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _items[row];
}

#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self notifyDelegate];
}

@end
