//
//  DBDeliveryTypeCell.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 20/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBDeliveryTypeCell : UITableViewCell
@property (strong, nonatomic, readonly) DBDeliveryType *deliveryType;

- (void)configureWithDeliveryType:(DBDeliveryType *)type;

@end
