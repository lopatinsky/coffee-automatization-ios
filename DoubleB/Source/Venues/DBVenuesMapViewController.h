//
//  DBVenuesMapViewController.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 13/01/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBVenuesViewController.h"

@interface DBVenuesMapViewController : UIViewController
@property (nonatomic, strong) NSString *eventsCategory;
@property (weak, nonatomic) id<DBVenuesControllerContainerDelegate> delegate;

- (void)update;
@end
