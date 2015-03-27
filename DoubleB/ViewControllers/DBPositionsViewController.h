//
//  DBPositionsViewController.h
//  DoubleB
//
//  Created by Sergey Pronin on 7/31/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
* First screen = Menu screen
*/
@interface DBPositionsViewController : UIViewController

/**
* Categories array with positions array
*/
@property (nonatomic, strong) NSMutableArray *positions; //@[ @[] ... ]
@property (nonatomic, strong) NSMutableArray *categories;

@end
