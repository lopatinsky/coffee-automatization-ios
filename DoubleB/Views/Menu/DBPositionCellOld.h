//
//  DBPositionCell.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 07.12.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBMenuPosition;

@interface DBPositionCellOld : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *positionCellContentView;
@property (weak, nonatomic) IBOutlet UILabel *positionTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *plusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *plusImageView;
@property (strong, nonatomic) DBMenuPosition *position;
@end
