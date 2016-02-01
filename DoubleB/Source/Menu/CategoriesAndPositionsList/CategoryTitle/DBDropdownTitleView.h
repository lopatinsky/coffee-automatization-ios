//
//  DBMenuCategoryDropdownTitleView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 03/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DBDropdownTitleViewState) {
    DBDropdownTitleViewStateNone = 0,
    DBDropdownTitleViewStateOpened,
    DBDropdownTitleViewStateClosed
};

@class DBDropdownTitleView;

@protocol DBMenuCategoryDropdownTitleViewDelegate <NSObject>
- (void)db_dropdownTitleClick:(DBDropdownTitleView *)view;
@end

@interface DBDropdownTitleView : UIView
@property (strong, nonatomic) NSString *title;
@property (nonatomic) DBDropdownTitleViewState state;

@property (weak, nonatomic) id<DBMenuCategoryDropdownTitleViewDelegate> delegate;

@end
