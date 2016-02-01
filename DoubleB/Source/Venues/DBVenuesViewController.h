//
//  DBVenuesViewController.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 14/01/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DBVenuesViewControllerMode) {
    DBVenuesViewControllerModeChooseVenue = 0,
    DBVenuesViewControllerModeList
};

@interface DBVenuesViewController : UIViewController
@property (nonatomic) DBVenuesViewControllerMode mode;
@property (nonatomic, strong) NSString *eventsCategory;
@end
