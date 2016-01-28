//
//  DBPositionViewController.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 21/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBModulesViewController.h"
#import "PositionViewControllerProtocol.h"

@interface DBPositionViewController : DBModulesViewController
@property (strong, nonatomic) DBMenuPosition *position;
@property (nonatomic) PositionViewControllerMode mode;
@end
