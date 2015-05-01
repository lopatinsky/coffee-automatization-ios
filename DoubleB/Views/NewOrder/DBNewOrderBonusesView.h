//
//  DBNewOrderBonusesView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 28.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBNewOrderBonusesView;

@protocol DBNewOrderBonusesViewDelegate <NSObject>
@required
- (void)db_newOrderBonusesView:(DBNewOrderBonusesView *)view didSelectBonuses:(BOOL)select;

@end

@interface DBNewOrderBonusesView : UIView
@property (strong, nonatomic) NSString *titleText;
@property (nonatomic) BOOL bonusSwitchActive;
@property (weak, nonatomic) id<DBNewOrderBonusesViewDelegate>delegate;

- (void)show:(BOOL)animated completion:(void(^)())completion;
- (void)hide:(BOOL)animated completion:(void(^)())completion;

@end
