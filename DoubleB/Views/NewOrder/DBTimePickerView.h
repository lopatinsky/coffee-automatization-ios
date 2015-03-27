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
- (void)db_timePickerView:(DBTimePickerView *)view didChangeMode:(DBBeverageMode)mode;
- (void)db_timePickerViewDidChooseTimeOption:(DBTimePickerView *)view;
@end

@interface DBTimePickerView : UIView
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSegmentedControl;

- (instancetype)initWithDelegate:(id<DBTimePickerViewDelegate>)delegate;

- (void)selectMode:(DBBeverageMode)mode;

@end
