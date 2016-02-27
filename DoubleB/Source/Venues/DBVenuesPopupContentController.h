//
//  DBVenuesPopupContentController.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 25/02/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBPopupViewController.h"
#import "DBBaseSettingsTableViewController.h"

@interface DBVenuesPopupContentController : UIViewController<DBPopupViewControllerContent, DBSettingsProtocol>
@property (nonatomic, strong) NSString *eventsCategory;
@end
