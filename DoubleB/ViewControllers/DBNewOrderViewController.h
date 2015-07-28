//
//  DBNewOrderViewController.h
//  DoubleB
//
//  Created by Balaban Alexander on 31/07/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kDBDefaultsFaves;

@class Order;

@interface DBNewOrderViewController : UIViewController 

@property (nonatomic, strong) Order *repeatedOrder;

@end
