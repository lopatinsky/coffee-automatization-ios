//
//  DBVenuesTableTableViewController.h
//  DoubleB
//
//  Created by Balaban Alexander on 31/07/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

//typedef NS_ENUM(NSUInteger, DBVenuesTableViewControllerMode) {
//    DBVenuesTableViewControllerModeChooseVenue = 0,
//    DBVenuesTableViewControllerModeList
//};

@interface DBVenuesTableViewController : UITableViewController
//@property (nonatomic) DBVenuesTableViewControllerMode mode;
@property (nonatomic, strong) NSString *eventsCategory;

@end
