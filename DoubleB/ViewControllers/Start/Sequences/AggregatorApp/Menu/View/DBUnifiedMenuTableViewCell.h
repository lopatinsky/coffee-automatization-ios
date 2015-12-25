//
//  DBUnifiedMenuTableViewCell.h
//  DoubleB
//
//  Created by Balaban Alexander on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBUnifiedMenuTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

- (void)setData:(NSDictionary *)info;

@end
