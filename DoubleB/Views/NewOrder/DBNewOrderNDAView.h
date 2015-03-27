//
//  DBNewOrderNDAView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 20.03.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBNewOrderNDAView;
@protocol DBNewOrderNDAViewDelegate <NSObject>

- (void)db_newOrderNDAViewDidTapNDALabel:(DBNewOrderNDAView *)ndaView;
- (void)db_newOrderNDAView:(DBNewOrderNDAView *)ndaView didSelectSwitchState:(BOOL)on;

@end

@interface DBNewOrderNDAView : UIView
@property(weak, nonatomic) id<DBNewOrderNDAViewDelegate> delegate;

- (void)show;
- (void)hide;

@end
