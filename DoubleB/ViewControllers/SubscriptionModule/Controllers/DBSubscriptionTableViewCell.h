//
//  DBSubscriptionTableViewCell.h
//  DoubleB
//
//  Created by Balaban Alexander on 21/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBSubscriptionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *desciptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *tickImageView;

@end
