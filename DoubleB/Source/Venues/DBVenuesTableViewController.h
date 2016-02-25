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
@property (nonatomic, strong) NSString *eventsCategory;

@property (weak, nonatomic) id<DBVenuesControllerContainerDelegate> delegate;
@end
