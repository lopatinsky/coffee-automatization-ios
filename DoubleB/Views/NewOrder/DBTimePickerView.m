//
//  DBTimePickerView.m
//  DoubleB
//
//  Created by Ощепков Иван on 17.02.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBTimePickerView.h"

@interface DBTimePickerView ()<UIGestureRecognizerDelegate>
@property(weak, nonatomic) id<DBTimePickerViewDelegate> delegate;
@property (weak, nonatomic) NSString *selectedModeName;
@end

@implementation DBTimePickerView

- (instancetype)initWithDelegate:(id<DBTimePickerViewDelegate>)delegate{
    DBTimePickerView *timePickerView = [[[NSBundle mainBundle] loadNibNamed:@"DBTimePickerView" owner:self options:nil] firstObject];
    timePickerView.delegate = delegate;
    return timePickerView;
}

- (void)awakeFromNib{
    self.pickerView.backgroundColor = [UIColor clearColor];
    
    self.typeSegmentedControl.tintColor = [UIColor db_defaultColor];
    [self.typeSegmentedControl addTarget:self
                                  action:@selector(segmentedControlValueChanged:)
                        forControlEvents:UIControlEventValueChanged];
    
    [self.typeSegmentedControl setTitle:NSLocalizedString(@"С собой", nil) forSegmentAtIndex:0];
    [self.typeSegmentedControl setTitle:NSLocalizedString(@"На месте", nil) forSegmentAtIndex:1];
    
    @weakify(self)
    UITapGestureRecognizer *tapGestureRecognizer = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self)
        CGPoint touchPoint = [sender locationInView:sender.view.superview];
        
        CGRect frame = self.pickerView.frame;
        CGRect selectorFrame = CGRectInset(frame, 0.0, self.pickerView.bounds.size.height * 0.85 / 2.0 );
        
        if (CGRectContainsPoint( selectorFrame, touchPoint) ){
            if ([self.delegate respondsToSelector:@selector(db_timePickerViewDidChooseTimeOption:)]) {
                [self.delegate db_timePickerViewDidChooseTimeOption:self];
            }
        }
    }];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    tapGestureRecognizer.delegate = self;
    [self.pickerView addGestureRecognizer:tapGestureRecognizer];
    self.pickerView.userInteractionEnabled = YES;
}

- (IBAction)segmentedControlValueChanged:(UISegmentedControl *)sender{
    DBBeverageMode selectedMode;
    switch (sender.selectedSegmentIndex) {
        case 0:
            selectedMode = DBBeverageModeTakeaway;
            self.selectedModeName = @"takeaway";
            break;
        case 1:
            selectedMode = DBBeverageModeInCafe;
            self.selectedModeName = @"in_cafe";
            break;
        default:
            selectedMode = DBBeverageModeTakeaway;
            self.selectedModeName = @"takeaway";
            break;
    }
    [GANHelper analyzeEvent:@"takeaway_switch_click" label:self.selectedModeName category:ORDER_SCREEN];
    
    if([self.delegate respondsToSelector:@selector(db_timePickerView:didChangeMode:)]){
        [self.delegate db_timePickerView:self didChangeMode:selectedMode];
    }
}

- (void)selectMode:(DBBeverageMode)mode{
    switch (mode) {
        case DBBeverageModeTakeaway:
            self.typeSegmentedControl.selectedSegmentIndex = 0;
            break;
        case DBBeverageModeInCafe:
            self.typeSegmentedControl.selectedSegmentIndex = 1;
            break;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

@end
