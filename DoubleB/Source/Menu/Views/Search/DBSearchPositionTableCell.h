//
//  DBSearchPositionTableCell.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 10/02/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DBMenuPosition;

@interface DBSearchPositionTableCell : UITableViewCell
@property (strong, nonatomic, readonly) DBMenuPosition *position;

+ (DBSearchPositionTableCell *)create;
- (void)configureWithPosition:(DBMenuPosition *)position;
@end
