//
//  DBTimePickerView.m
//  DoubleB
//
//  Created by Ощепков Иван on 17.02.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBTimePickerView.h"

@interface DBTimePickerView ()<UIGestureRecognizerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (nonatomic) double initialSegmentsViewHolderHeight;

@property (weak, nonatomic) id<DBTimePickerViewDelegate> delegate;

@property (strong, nonatomic) UIImageView *overlay;
@property (weak, nonatomic) UIView *viewHolder;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

// Only for DBTimePickerTypeDateAndItems
@property (strong, nonatomic) NSArray *dateItems;

@end

@implementation DBTimePickerView

- (instancetype)initWithDelegate:(id<DBTimePickerViewDelegate>)delegate {
    DBTimePickerView *timePickerView = [[[NSBundle mainBundle] loadNibNamed:@"DBTimePickerView" owner:self options:nil] firstObject];
    timePickerView.delegate = delegate;
    timePickerView.dateFormatter = [NSDateFormatter new];
    timePickerView.dateFormatter.dateFormat = @"ccc d";
    return timePickerView;
}

- (void)awakeFromNib {
    self.backgroundColor = [UIColor whiteColor];
    
    self.pickerView.backgroundColor = [UIColor clearColor];
    self.pickerView.delegate = self;
    
    self.datePickerView.backgroundColor = [UIColor clearColor];
    
    @weakify(self)
    UITapGestureRecognizer *tapGestureRecognizer = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self)
        CGPoint touchPoint = [sender locationInView:sender.view.superview];
        
        CGRect frame = self.pickerView.frame;
        CGRect selectorFrame = CGRectInset(frame, 0.0, self.pickerView.bounds.size.height * 0.85 / 2.0 );
        
        if (CGRectContainsPoint( selectorFrame, touchPoint) ){
            [self hideInternal];
        }
    }];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    tapGestureRecognizer.delegate = self;
    [self.pickerView addGestureRecognizer:tapGestureRecognizer];
    self.pickerView.userInteractionEnabled = YES;
    
    [self.doneButton setTitle:NSLocalizedString(@"Готово", nil) forState:UIControlStateNormal];
    [self.doneButton setTitleColor:[UIColor db_defaultColor] forState:UIControlStateNormal];
}

- (void)configure {
    // Hack for repare iOS9 bug
    [self.datePickerView setDatePickerMode:UIDatePickerModeDateAndTime];
    [self.datePickerView setDatePickerMode:UIDatePickerModeTime];
    
    if(_type == DBTimePickerTypeDateTime || _type == DBTimePickerTypeTime){
        self.datePickerView.hidden = NO;
        self.pickerView.hidden = YES;
        
        if(_type == DBTimePickerTypeDateTime){
            self.datePickerView.datePickerMode = UIDatePickerModeDateAndTime;
        }
        if(_type == DBTimePickerTypeTime){
            self.datePickerView.datePickerMode = UIDatePickerModeTime;
        }
    }
    
    if (_type == DBTimePickerTypeItems) {
        self.datePickerView.hidden = YES;
        self.pickerView.hidden = NO;
        
        [self.pickerView reloadAllComponents];
    }
    
    if (_type == DBTimePickerTypeDateAndItems) {
        self.datePickerView.hidden = YES;
        
        [self setupDates];
        [self.pickerView reloadAllComponents];
    }
}

- (IBAction)doneButtonClicked {
    [self hideInternal];
}

- (void)setType:(DBTimePickerType)type{
    _type = type;
}

- (void)setItems:(NSArray *)items{
    _items = items;
    
    [self.pickerView reloadAllComponents];
}

- (void)setSelectedItem:(NSInteger)selectedItem{
    int component = self.type == DBTimePickerTypeDateAndItems ? 1 : 0;
    
    if(selectedItem < 0 || selectedItem  >= [self.pickerView numberOfRowsInComponent:0]){
        selectedItem = 0;
    }
    
    [self.pickerView selectRow:selectedItem inComponent:component animated:YES];
}

- (NSInteger)selectedItem{
    return [self.pickerView selectedRowInComponent:1];
}

- (void)setSelectedDate:(NSDate *)selectedDate{
    _selectedDate = selectedDate;
    
    if(self.type == DBTimePickerTypeDateAndItems){
        [self.pickerView selectRow:[self rowForDate:_selectedDate] inComponent:0 animated:YES];
    } else {
        self.datePickerView.date = _selectedDate;
    }
}

- (IBAction)datePickerValueChanged:(id)sender {
    self.selectedDate = self.datePickerView.date;
}

- (void)showOnView:(UIView *)view{
    self.viewHolder = view;
    
    [self configure];
    [self show];
}

- (void)hide{
    [self dismiss];
}

- (void)hideInternal {
    // Call Delegate only when view will dismiss(cause delegate vc show alert after handling)
    if(self.type == DBTimePickerTypeTime || self.type == DBTimePickerTypeDateTime){
        if([self.delegate respondsToSelector:@selector(db_timePickerView:didSelectDate:)]){
            [self.delegate db_timePickerView:self didSelectDate:self.selectedDate];
        }
    }
    
    if([self.delegate respondsToSelector:@selector(db_shouldHideTimePickerView)]){
        if([self.delegate db_shouldHideTimePickerView]){
            [self dismiss];
        }
    } else {
        [self dismiss];
    }
}

- (void)show {
    self.overlay = [[UIImageView alloc] initWithFrame:self.viewHolder.bounds];
    self.overlay.image = [[self.viewHolder snapshotImage] applyBlurWithRadius:5 tintColor:[UIColor colorWithWhite:0.3 alpha:0.6] saturationDeltaFactor:1.5 maskImage:nil];
    self.overlay.alpha = 0;
    self.overlay.userInteractionEnabled = YES;
    [self.overlay addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideInternal)]];
    [self.viewHolder addSubview:self.overlay];
    
    CGRect rect = self.frame;
    rect.origin.y = self.viewHolder.bounds.size.height;
    rect.size.width = self.viewHolder.bounds.size.width;
    self.frame = rect;
    
    [self.viewHolder addSubview:self];
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.frame;
        frame.origin.y -= self.bounds.size.height;
        self.frame = frame;
        
        self.overlay.alpha = 1;
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.2 animations:^{
        self.overlay.alpha = 0;
        CGRect rect = self.frame;
        rect.origin.y = self.viewHolder.bounds.size.height;
        self.frame = rect;
    } completion:^(BOOL f){
        [self.overlay removeFromSuperview];
        [self removeFromSuperview];
    }];
}

#pragma mark - Date(items) helper methods

- (void)setupDates{
    NSMutableArray *dayItems = [NSMutableArray new];
    for(int i = 0; i < [self daysBetweenDate:self.minDate andDate:self.maxDate]; i++){
        NSDate *date = [self dateForRow:i];
        
        NSString *dayString = [self stringOfDate:date];
        [dayItems addObject:dayString];
    }
    
    self.dateItems = dayItems;
}

- (NSDate *)dateForRow:(NSInteger)row{
    NSDate *date = [NSDate dateWithTimeInterval:60 * 60 * 24 * row sinceDate:self.minDate];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit) fromDate:date];
    
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

- (NSInteger)rowForDate:(NSDate *)date{
    NSString *dayString = [self stringOfDate:date];
    
    NSInteger index = [self.dateItems indexOfObject:dayString];
    if(index == NSNotFound){
        index = 0;
    }
    
    return index;
}

- (NSString *)stringOfDate:(NSDate *)date{
    if ([self isDate:date sameDayAsDate:[NSDate date]]) {
        return NSLocalizedString(@"Сегодня", nil);
    }
    return [self.dateFormatter stringFromDate:date];
}

- (BOOL)isDate:(NSDate *)date1 sameDayAsDate:(NSDate *)date2 {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}

- (NSInteger)daysBetweenDate:(NSDate *)fromDateTime andDate:(NSDate *)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    return [difference day];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    switch (_type) {
        case DBTimePickerTypeDateAndItems:
            return 2;
            break;
        case DBTimePickerTypeDateTime:
        case DBTimePickerTypeItems:
        case DBTimePickerTypeTime:
            return 1;
            break;
        default:
            return 0;
            break;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (_type) {
        case DBTimePickerTypeDateAndItems:
            if (component == 0) {
                return [self daysBetweenDate:self.minDate andDate:self.maxDate];
            } else {
                return [_items count];
            }
            break;
        case DBTimePickerTypeDateTime:
        case DBTimePickerTypeItems:
        case DBTimePickerTypeTime:
            return [_items count];
            break;
        default:
            return 0;
            break;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (_type) {
        case DBTimePickerTypeDateAndItems:
            if (component == 0) {
                return self.dateItems[row];
            } else {
                return _items[row];
            }
            break;
        case DBTimePickerTypeDateTime:
        case DBTimePickerTypeItems:
        case DBTimePickerTypeTime:
            return _items[row];
            break;
        default:
            return 0;
            break;
    }
    return _items[row];
}

#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if(_type == DBTimePickerTypeDateAndItems){
        if(component == 0){
            self.selectedDate = [self dateForRow:row];
            if([self.delegate respondsToSelector:@selector(db_timePickerView:didSelectDate:)]){
                [self.delegate db_timePickerView:self didSelectDate:self.selectedDate];
            }
        } else {
            self.selectedItem = row;
            if([self.delegate respondsToSelector:@selector(db_timePickerView:didSelectRowAtIndex:)]){
                [self.delegate db_timePickerView:self didSelectRowAtIndex:row];
            }
        }
    } else {
        self.selectedItem = row;
        if([self.delegate respondsToSelector:@selector(db_timePickerView:didSelectRowAtIndex:)]){
            [self.delegate db_timePickerView:self didSelectRowAtIndex:row];
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

@end
