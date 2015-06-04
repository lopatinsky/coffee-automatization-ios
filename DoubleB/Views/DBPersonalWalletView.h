//
//  DBPersonalWalletView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 03.06.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBPersonalWalletView;
@protocol DBPersonalWalletViewDelegate <NSObject>
- (void)db_personalWalletView:(DBPersonalWalletView *)view didUpdateBalance:(double)balance;
@end

@interface DBPersonalWalletView : UIView
@property(weak, nonatomic) id<DBPersonalWalletViewDelegate> delegate;

- (void)showOnView:(UIView *)view;
- (void)hide;

@end
