//
//  OrderViewFooter.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 07.02.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@class Order;

@interface DBOrderViewFooter : UIView
@property (weak, nonatomic) IBOutlet UILabel *labelTotal;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UILabel *labelAddress;

- (instancetype)initWithFrame:(CGRect)rect order:(Order *)order;
- (instancetype)initWithOrder:(Order *)order;

@end
