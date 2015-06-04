//
//  DBTimePickerView.m
//  DoubleB
//
//  Created by Ощепков Иван on 17.02.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBTimePickerView.h"

@interface DBTimePickerView ()<UIGestureRecognizerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *segmentsViewHolder;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintSegmentsViewHolderHeight;
@property (nonatomic) double initialSegmentsViewHolderHeight;

@property (weak, nonatomic) id<DBTimePickerViewDelegate> delegate;

@property (strong, nonatomic) UIImageView *overlay;
@property (weak, nonatomic) UIView *viewHolder;

@end

@implementation DBTimePickerView

- (instancetype)initWithDelegate:(id<DBTimePickerViewDelegate>)delegate{
    DBTimePickerView *timePickerView = [[[NSBundle mainBundle] loadNibNamed:@"DBTimePickerView" owner:self options:nil] firstObject];
    timePickerView.delegate = delegate;
    return timePickerView;
}

- (void)awakeFromNib{
    self.backgroundColor = [UIColor whiteColor];
    
    self.pickerView.backgroundColor = [UIColor clearColor];
    self.pickerView.delegate = self;
    
    self.datePickerView.backgroundColor = [UIColor clearColor];
    
    self.typeSegmentedControl.tintColor = [UIColor db_defaultColor];
    [self.typeSegmentedControl addTarget:self
                                  action:@selector(segmentedControlValueChanged:)
                        forControlEvents:UIControlEventValueChanged];
    
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
    
    self.initialSegmentsViewHolderHeight = self.constraintSegmentsViewHolderHeight.constant;
}

- (void)configure{
    if(_type == DBTimePickerTypeDate || _type == DBTimePickerTypeTime){
        self.datePickerView.hidden = NO;
        self.pickerView.hidden = YES;
        
        if(_type == DBTimePickerTypeDate){
            self.datePickerView.datePickerMode = UIDatePickerModeDateAndTime;
        }
        if(_type == DBTimePickerTypeTime){
            self.datePickerView.datePickerMode = UIDatePickerModeTime;
        }
    }
    
    if(_type == DBTimePickerTypeItems){
        self.datePickerView.hidden = YES;
        self.pickerView.hidden = NO;
        
        [self.pickerView reloadAllComponents];
    }
    
    if(_segments.count < 2){
        self.constraintSegmentsViewHolderHeight.constant = 0;
    } else {
        self.constraintSegmentsViewHolderHeight.constant = self.initialSegmentsViewHolderHeight;
    }
    
    CGRect rect = self.frame;
    rect.size.height = self.constraintSegmentsViewHolderHeight.constant + self.datePickerView.frame.size.height;
    self.frame = rect;
}

- (void)setType:(DBTimePickerType)type{
    _type = type;
}

- (void)setSegments:(NSArray *)segments{
    _segments = segments;
    
    [self.typeSegmentedControl removeAllSegments];
    for(int i = 0; i < [_segments count]; i++){
        [self.typeSegmentedControl insertSegmentWithTitle:_segments[i] atIndex:i animated:NO];
    }
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex{
    _selectedSegmentIndex = selectedSegmentIndex;
    if(selectedSegmentIndex < 0 || selectedSegmentIndex >= self.typeSegmentedControl.numberOfSegments){
        _selectedSegmentIndex = 0;
    }
    
    self.typeSegmentedControl.selectedSegmentIndex = _selectedSegmentIndex;
}

- (void)setItems:(NSArray *)items{
    _items = items;
    
    [self.pickerView reloadAllComponents];
}

- (void)setSelectedItem:(NSInteger)selectedItem{
    _selectedItem = selectedItem;
    if(_selectedItem < 0 || _selectedItem  >=[self.pickerView numberOfRowsInComponent:0]){
        _selectedItem = 0;
    }
    [self.pickerView selectRow:_selectedItem inComponent:0 animated:YES];
}

- (void)setSelectedDate:(NSDate *)selectedDate{
    _selectedDate = selectedDate;
    self.datePickerView.date = _selectedDate;
}

- (IBAction)segmentedControlValueChanged:(UISegmentedControl *)sender{
    if([self.delegate respondsToSelector:@selector(db_timePickerView:didSelectSegmentAtIndex:)]){
        [self.delegate db_timePickerView:self didSelectSegmentAtIndex:sender.selectedSegmentIndex];
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

- (void)hideInternal{
    if(_type == DBTimePickerTypeItems){
        if([self.delegate respondsToSelector:@selector(db_timePickerView:didSelectRowAtIndex:)]){
            [self.delegate db_timePickerView:self didSelectRowAtIndex:self.selectedItem];
        }
    } else {
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

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.selectedItem = row;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

@end
