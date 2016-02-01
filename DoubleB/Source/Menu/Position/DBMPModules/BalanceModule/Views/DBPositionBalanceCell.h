//
//  PositionBalanceCell.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 30/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBPositionBalanceCell : UITableViewCell
@property (nonatomic) BOOL tickAvailable;
@property (nonatomic) BOOL tickSelected;
- (void)configure:(DBMenuPositionBalance *)balance;
@end
