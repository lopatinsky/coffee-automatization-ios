//
//  DBDeliveryViewController.h
//  DoubleB
//
//  Created by Dmitriy Stupivtsev on 05.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DBVenuesTableViewController.h"
#import "DBDeliveryViewController.h"

@interface DBAddressViewController : UIViewController<KeyboardAppearance>

@property (strong, nonatomic) id<DBVenuesTableViewControllerDelegate> delegate;

@end
