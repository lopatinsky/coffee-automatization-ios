//
//  DBOrderViewController.h
//  DoubleB
//
//  Created by Balaban Alexander on 01/08/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"

@interface DBOrderViewController : UIViewController

@property (nonatomic, strong) Order *order;

@property(nonatomic) BOOL scrollContentToBottom;

@end
