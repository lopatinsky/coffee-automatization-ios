//
//  DBNewOrderItemAdditionView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 20.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBNewOrderItemAdditionView;
@protocol DBNewOrderItemAdditionViewDelegate <NSObject>
- (void)db_newOrderItemAdditionViewDidSelectPositions:(DBNewOrderItemAdditionView *)view;
- (void)db_newOrderItemAdditionViewDidSelectBonusPositions:(DBNewOrderItemAdditionView *)view;

@end

@interface DBNewOrderItemAdditionView : UIView
@property (weak, nonatomic) id<DBNewOrderItemAdditionViewDelegate> delegate;

@property (nonatomic) BOOL showBonusPositionsView;

- (void)showBonusPositionsView:(BOOL)showBonusPositionsView animated:(BOOL)animated;
@end
