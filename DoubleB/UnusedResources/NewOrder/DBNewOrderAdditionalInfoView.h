//
//  DBNewOrderAdditionalInfoView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 20.03.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBNewOrderAdditionalInfoView : UIView

- (void)showPromos:(NSArray *)promos completion:(void(^)())completion;
- (void)showPromos:(NSArray *)promos animation:(void(^)())animation completion:(void(^)())completion;

- (void)showErrors:(NSArray *)errors completion:(void(^)())completion;
- (void)showErrors:(NSArray *)errors animation:(void(^)())animation completion:(void(^)())completion;

- (void)hide:(void(^)())animation completion:(void(^)())completion;

@end
