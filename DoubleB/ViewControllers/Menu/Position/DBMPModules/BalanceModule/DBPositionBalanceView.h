//
//  DBPositionBalanceViewController.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 30/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBPopupViewController.h"

typedef NS_ENUM(NSInteger, DBPositionBalanceViewMode) {
    DBPositionBalanceViewModeBalance = 0,
    DBPositionBalanceViewModeChooseVenue
};

@class Venue;

@interface DBPositionBalanceView : UIView<DBPopupViewControllerContent>
@property (strong, nonatomic) DBMenuPosition *position;
@property (strong, nonatomic) NSArray *balance;
@property (nonatomic) DBPositionBalanceViewMode mode;

@property (nonatomic, copy) void (^venueSelectedBlock)(Venue *);

- (void)reload;

@end
