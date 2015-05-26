//
//  DBTimePickerView.m
//  DoubleB
//
//  Created by Ощепков Иван on 17.02.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBTimePickerView.h"

@interface DBTimePickerView ()<UIGestureRecognizerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) id<DBTimePickerViewDelegate> delegate;
@property (weak, nonatomic) NSString *selectedModeName;

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
    self.pickerView.backgroundColor = [UIColor clearColor];
    self.pickerView.delegate = self;
    
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
}

- (IBAction)segmentedControlValueChanged:(UISegmentedControl *)sender{
    if([self.delegate respondsToSelector:@selector(db_timePickerView:didSelectSegmentAtIndex:)]){
        [self.delegate db_timePickerView:self didSelectSegmentAtIndex:sender.selectedSegmentIndex];
    }
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex{
    _selectedSegmentIndex = selectedSegmentIndex;
    if(selectedSegmentIndex >= 0 && selectedSegmentIndex < self.typeSegmentedControl.numberOfSegments){
        self.typeSegmentedControl.selectedSegmentIndex = _selectedSegmentIndex;
    }
}

- (void)setSelectedRow:(NSInteger)selectedRow{
    _selectedRow = selectedRow;
    if(selectedRow >= 0 && selectedRow < [self.pickerView numberOfRowsInComponent:0]){
        [self.pickerView selectRow:_selectedRow inComponent:0 animated:YES];
    }
}

- (void)showOnView:(UIView *)view{
    self.viewHolder = view;
    
    NSInteger numberOfSegments = [self.delegate db_numberOfSegmentsInTimePickerView:self];
    
    [self.typeSegmentedControl removeAllSegments];
    for(int i = 0; i < numberOfSegments; i++){
        [self.typeSegmentedControl insertSegmentWithTitle:[self.delegate db_timePickerView:self titleForSegmentAtIndex:i] atIndex:i animated:NO];
    }
    
    [self.pickerView reloadAllComponents];
    
    [self setSelectedSegmentIndex:self.selectedSegmentIndex];
    [self setSelectedRow:self.selectedRow];
    
    [self show];
}

- (void)hide{
    [self dismiss];
}

- (void)hideInternal{
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
    if([self.delegate respondsToSelector:@selector(db_numberOfRowsInTimePickerView:)]){
        return [self.delegate db_numberOfRowsInTimePickerView:self];
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if([self.delegate respondsToSelector:@selector(db_timePickerView:titleForRowAtIndex:)]){
        return [self.delegate db_timePickerView:self titleForRowAtIndex:row];
    }
    return 0;
}

#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if([self.delegate respondsToSelector:@selector(db_timePickerViewDidSelectRowAtIndex:)]){
        return [self.delegate db_timePickerViewDidSelectRowAtIndex:row];
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
