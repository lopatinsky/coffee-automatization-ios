//
//  DBVenuesTableTableViewController.h
//  DoubleB
//
//  Created by Balaban Alexander on 31/07/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBVenuesTableViewController;
@class Venue;

@protocol DBVenuesTableViewControllerDelegate <NSObject>
- (void)venuesController:(DBVenuesTableViewController *)controller didChooseVenue:(Venue *)venue;
@end

@interface DBVenuesTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *venues;
@property (nonatomic, weak) id<DBVenuesTableViewControllerDelegate> delegate;

@end
