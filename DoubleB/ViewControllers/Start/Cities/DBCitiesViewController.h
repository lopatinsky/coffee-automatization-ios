//
//  DBCitiesViewController.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBCity;
@protocol DBCitiesViewControllerDelegate <NSObject>

- (void)db_citiesViewControllerDidSelectCity:(DBCity *)city;

@end

@interface DBCitiesViewController : UIViewController
@property (weak, nonatomic) id<DBCitiesViewControllerDelegate> delegate;
@end
