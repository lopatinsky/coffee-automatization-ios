//
//  DBPositionViewController.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 03.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBMenuPosition;

@interface DBPositionViewController : UIViewController
@property (strong, nonatomic) DBMenuPosition *position;

- (instancetype)initWithPosition:(DBMenuPosition *)position;
@end
