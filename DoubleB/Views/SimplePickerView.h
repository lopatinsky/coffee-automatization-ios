//
//  SimplePickerView.h
//  DoubleB
//
//  Created by Balaban Alexander on 11/06/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SimplePickerView;

@protocol SimplePickerViewDelegate <NSObject>

- (void)db_simplePickerView:(nonnull SimplePickerView *)view didSelectSegmentAtIndex:(NSInteger)index;
- (void)db_simplePickerView:(nonnull SimplePickerView *)view didSelectRowAtIndex:(NSInteger)index;
- (void)db_simplePickerView:(nonnull SimplePickerView *)view didSelectItem:(nonnull NSString *)item;
- (BOOL)db_shouldHideSimplePickerView;

@end

@interface SimplePickerView : UIView

@property (strong, nonatomic) IBOutlet UIPickerView * __nullable simplePickerView;

@property (strong, nonatomic) NSArray * __nonnull items;
@property (nonatomic) NSInteger selectedSegmentIndex;
@property (nonatomic) NSInteger selectedItem;

- (nonnull instancetype)initWithDelegate:(nonnull id<SimplePickerViewDelegate>)delegate;
- (void)showOnView:(nonnull UIView *)view;
- (void)dismiss;

@end
