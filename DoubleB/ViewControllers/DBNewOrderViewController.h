//
//  DBNewOrderViewController.h
//  DoubleB
//
//  Created by Balaban Alexander on 31/07/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kDBDefaultsFaves;

@class DBNewOrderViewController;
@class Order;

@protocol DBNewOrderViewControllerDelegate <NSObject>
- (void)newOrderViewController:(DBNewOrderViewController *)controller didFinishOrder:(Order *)order;
@end

@interface DBNewOrderViewController : UIViewController 

@property (nonatomic, strong) Order *repeatedOrder;
@property (nonatomic, weak) id<DBNewOrderViewControllerDelegate> delegate;

@end
