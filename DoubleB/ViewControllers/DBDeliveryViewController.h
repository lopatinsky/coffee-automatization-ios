//
//  DBDeliveryViewController.h
//  DoubleB
//
//  Created by Dmitriy Stupivtsev on 10.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DBDeliveryViewControllerDataSource <NSObject>

- (UIView *)superView;

@end

@interface DBDeliveryViewController : UIViewController
- (void)addToDataSource:(id<DBDeliveryViewControllerDataSource>)dataSource;
@end
