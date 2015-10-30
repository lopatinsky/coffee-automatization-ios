//
//  DBShippingAutocompleteCell.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 30/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBShippingAddress;
@interface DBShippingAutocompleteCell : UITableViewCell
- (void)configureWithAddress:(DBShippingAddress *)address;
@end
