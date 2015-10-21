//
//  IHPickerView.h
//  IIkoHackathon
//
//  Created by Ivan Oschepkov on 13/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBPopupViewComponent.h"

@class DBPickerView;
@protocol DBPickerViewDelegate <NSObject>
@optional
- (void)db_pickerView:(DBPickerView *)view didSelectRow:(NSString *)row;
- (void)db_pickerView:(DBPickerView *)view didSelectRowAtIndex:(NSUInteger)rowIndex;

@end

@interface DBPickerView : DBPopupViewComponent
@property (weak, nonatomic) id<DBPickerViewDelegate, DBPopupViewComponentDelegate> pickerDelegate;
@property (strong, nonatomic) NSString *title;

- (void)configureWithItems:(NSArray *)items;
@property (nonatomic) NSUInteger selectedIndex;

@end
