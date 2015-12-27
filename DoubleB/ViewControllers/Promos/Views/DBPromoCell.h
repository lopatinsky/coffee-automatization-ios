//
//  DBPromoCell.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 02.06.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBPromotion;

@interface DBPromoCell : UITableViewCell
- (void)configureWithPromo:(DBPromotion *)promo;

//- (CGFloat *)contentHeight;
@end
