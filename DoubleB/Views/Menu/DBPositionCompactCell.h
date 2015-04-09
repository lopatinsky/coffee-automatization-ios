//
//  DBPositionCell.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 07.12.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBPositionCell.h"

@class DBMenuPosition;

@interface DBPositionCompactCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *positionCellContentView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *orderButton;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (strong, nonatomic) DBMenuPosition *position;

@property (nonatomic, weak) id<DBPositionCellDelegate> delegate;

- (void)configureWithPosition:(DBMenuPosition *)position;
@end
