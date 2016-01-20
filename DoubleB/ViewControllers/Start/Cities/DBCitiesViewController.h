//
//  DBCitiesViewController.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBBaseSettingsTableViewController.h"

@class DBUnifiedCity;
@protocol DBCitiesViewControllerDelegate <NSObject>

- (void)db_citiesViewControllerDidSelectCity:(DBUnifiedCity *)city;

@end

@interface DBCitiesViewController : UIViewController <DBSettingsProtocol>
@property (weak, nonatomic) id<DBCitiesViewControllerDelegate> delegate;
@end
