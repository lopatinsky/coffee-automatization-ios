//
//  DBOrderReturnView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 13.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"

@class DBOrderReturnView;
@protocol DBOrderReturnViewDelegate <NSObject>
@optional
- (void)db_orderReturnViewDidCancel:(DBOrderReturnView *)view;
@required
- (void)db_orderReturnView:(DBOrderReturnView *)view DidSelectCause:(DBOrderCancelReason)cause;
- (void)db_orderReturnView:(DBOrderReturnView *)view DidSelectOtherCause:(NSString *)cause;
@end

@interface DBOrderReturnView : UIView
@property (weak, nonatomic) id<DBOrderReturnViewDelegate> delegate;

- (void)showOnView:(UIView *)view;
- (void)hide;
@end
