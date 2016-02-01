//
//  IHPickerView.h
//  IIkoHackathon
//
//  Created by Ivan Oschepkov on 13/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBPopupComponent.h"

@class DBPickerView;
@protocol DBPickerViewDelegate <NSObject>
@optional
- (void)db_pickerView:(DBPickerView *)view didSelectRow:(NSString *)row;
- (void)db_pickerView:(DBPickerView *)view didSelectRowAtIndex:(NSUInteger)rowIndex;

@end

@interface DBPickerView : DBPopupComponent
@property (weak, nonatomic) id<DBPickerViewDelegate, DBPopupComponentDelegate> pickerDelegate;
@property (strong, nonatomic) NSString *title;

- (void)configureWithItems:(NSArray *)items;
@property (nonatomic) NSUInteger selectedIndex;

@end
