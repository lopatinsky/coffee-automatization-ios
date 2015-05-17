//
//  DBInfiniteScrollViewController.h
//  DoubleB
//
//  Created by Dmitriy Stupivtsev on 30.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBMenuPosition.h"
#import "DBMenuCategory.h"

@interface DBPositionScrollViewController : UIViewController
- (instancetype)initWithPosition:(DBMenuPosition *)position categories:(NSArray *)categories;
@end
