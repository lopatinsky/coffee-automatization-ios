//
//  DBSubscriptionTableViewController.h
//  DoubleB
//
//  Created by Balaban Alexander on 21/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubscriptionViewControllerProtocol.h"

@interface DBSubscriptionTableViewController : UITableViewController<SubscriptionViewControllerProtocol>

@property (nonatomic, strong) UIViewController<SubscriptionViewControllerDelegate> *delegate;

@end
