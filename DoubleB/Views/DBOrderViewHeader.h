//
//  DBOrderViewHeader.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 07.02.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Order;

@interface DBOrderViewHeader : UIView
@property (weak, nonatomic) IBOutlet UILabel *labelOrder;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UILabel *labelPaymentStatus;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewPaymentStatus;

- (instancetype)initWithOrder:(Order *)order;
@end
