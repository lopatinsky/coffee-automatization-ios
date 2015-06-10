//
//  DBCardCell.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 10.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBCardCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *cardIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *cardTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cardActiveIndicator;

@property (nonatomic) BOOL checked;

@end
