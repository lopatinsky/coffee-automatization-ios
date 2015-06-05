//
//  DBNewOrderItemErrorView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 05.06.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DBNewOrderItemErrorViewMode) {
    DBNewOrderItemErrorViewModeDelete = 0,
    DBNewOrderItemErrorViewModeReplace
};

@class DBNewOrderItemErrorView;
@protocol DBNewOrderItemErorViewDelegate <NSObject>
- (void)db_newOrderItemErrorViewDidTap:(DBNewOrderItemErrorView *)view;
- (void)db_newOrderItemErrorView:(DBNewOrderItemErrorView *)view didSelectAction:(DBNewOrderItemErrorViewMode)actionMode;

@end

@interface DBNewOrderItemErrorView : UIView
@property (nonatomic) DBNewOrderItemErrorViewMode mode;
@property (strong, nonatomic) NSString *message;
@property (weak, nonatomic) id<DBNewOrderItemErorViewDelegate> delegate;

@property (nonatomic) BOOL isOpen;

- (void)moveContentLeft;
- (void)moveContentRight;

- (void)showOnView:(UIView *)view inFrame:(CGRect)rect;
- (void)hide;
@end
