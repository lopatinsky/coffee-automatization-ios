//
//  SimplePickerView.m
//  DoubleB
//
//  Created by Balaban Alexander on 11/06/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "SimplePickerView.h"

@interface SimplePickerView()<UIGestureRecognizerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) id<SimplePickerViewDelegate> delegate;

@property (strong, nonatomic) UIImageView *overlay;

@end

@implementation SimplePickerView

- (instancetype)initWithDelegate:(nonnull id<SimplePickerViewDelegate>)delegate {
    self = [[[NSBundle mainBundle] loadNibNamed:@"SimplePickerView" owner:self options:nil] firstObject];
    self.delegate = delegate;
    return self;
}

- (void)awakeFromNib {
    self.simplePickerView.backgroundColor = [UIColor clearColor];
    
    @weakify(self)
    UITapGestureRecognizer *tapGestureRecognizer = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self)
        CGPoint touchPoint = [sender locationInView:sender.view.superview];
        
        CGRect frame = self.simplePickerView.frame;
        CGRect selectorFrame = CGRectInset(frame, 0.0, self.simplePickerView.bounds.size.height * 0.85 / 2.0 );
        
        if (CGRectContainsPoint( selectorFrame, touchPoint) ){
            [self hideInternal];
        }
    }];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    tapGestureRecognizer.delegate = self;
    
    [self.simplePickerView addGestureRecognizer:tapGestureRecognizer];
    self.simplePickerView.userInteractionEnabled = YES;
}

- (void)setItems:(NSArray *)items{
    _items = items;
    
    [self.simplePickerView reloadAllComponents];
}

- (void)setSelectedItem:(NSInteger)selectedItem{
    _selectedItem = selectedItem;
    [self.simplePickerView selectRow:_selectedItem inComponent:0 animated:YES];
}

- (void)showOnView:(UIView *)view {
    self.overlay = [[UIImageView alloc] initWithFrame:view.bounds];
    self.overlay.image = [[view snapshotImage] applyBlurWithRadius:5 tintColor:[UIColor colorWithWhite:0.3 alpha:0.6] saturationDeltaFactor:1.5 maskImage:nil];
    self.overlay.alpha = 0;
    self.overlay.userInteractionEnabled = YES;
    [self.overlay addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideInternal)]];
    [view addSubview:self.overlay];
    
    CGRect rect = self.frame;
    rect.origin.y = view.bounds.size.height;
    rect.size.width = view.bounds.size.width;
    self.frame = rect;
    
//    [view addSubview:self];
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.frame;
        frame.origin.y -= self.bounds.size.height;
        self.frame = frame;
        
        self.overlay.alpha = 1;
    }];
}

- (void)hide {
    [self dismiss];
}

- (void)hideInternal {
    if ([self.delegate respondsToSelector:@selector(db_simplePickerView:didSelectRowAtIndex:)]){
        [self.delegate db_simplePickerView:self didSelectRowAtIndex:self.selectedItem];
    }
    if ([self.delegate respondsToSelector:@selector(db_shouldHideSimplePickerView)]){
        if([self.delegate db_shouldHideSimplePickerView]){
            [self dismiss];
        }
    } else {
        [self dismiss];
    }
}

- (void)show {
}

- (void)dismiss {
    [UIView animateWithDuration:0.2 animations:^{
        self.overlay.alpha = 0;
        CGRect rect = self.frame;
        rect.origin.y = self.superview.bounds.size.height;
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
