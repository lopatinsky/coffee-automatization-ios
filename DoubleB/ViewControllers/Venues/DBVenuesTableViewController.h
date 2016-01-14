//
//  DBVenuesTableTableViewController.h
//  DoubleB
//
//  Created by Balaban Alexander on 31/07/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBVenuesViewController.h"

@interface DBVenuesTableViewController : UITableViewController
@property (nonatomic) DBVenuesViewControllerMode mode;
@property (nonatomic, strong) NSString *eventsCategory;

@end
