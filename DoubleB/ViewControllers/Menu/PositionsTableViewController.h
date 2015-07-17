//
//  DBPositionsViewController.h
//  DoubleB
//
//  Created by Sergey Pronin on 7/31/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PositionsViewControllerProtocol.h"

@interface PositionsTableViewController : UITableViewController <PositionsViewControllerProtocol>

+ (instancetype)createViewController;

@end
