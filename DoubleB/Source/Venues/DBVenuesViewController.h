//
//  DBVenuesViewController.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 14/01/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBBaseSettingsTableViewController.h"

typedef NS_ENUM(NSUInteger, DBVenuesViewControllerMode) {
    DBVenuesViewControllerModeChooseVenue = 0,
    DBVenuesViewControllerModeList
};

@protocol DBVenuesControllerContainerDelegate <NSObject>
@required
- (BOOL)db_venuesControllerContentSelectEnabled:(NSObject *)sender;
- (BOOL)db_venuesControllerContentSelectInfoEnabled:(NSObject *)sender;

- (void)db_venuesControllerContentDidSelectVenue:(Venue *)venue;
- (void)db_venuesControllerContentDidSelectVenueInfo:(Venue *)venue;
@end

@interface DBVenuesViewController : UIViewController<DBSettingsProtocol>
@property (nonatomic) DBVenuesViewControllerMode mode;
@property (nonatomic, strong) NSString *eventsCategory;
@end
