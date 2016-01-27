//
//  SubscriptionInfoTableViewCell.m
//  DoubleB
//
//  Created by Balaban Alexander on 21/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "SubscriptionInfoTableViewCell.h"
#import "ViewControllerManager.h"

@implementation SubscriptionInfoTableViewCell

- (void)awakeFromNib {
    [self.cupImage templateImageWithName:@"mug" tintColor:[UIColor db_defaultColor]];
    [self.buyButton setBackgroundColor:[UIColor db_defaultColor]];
    self.buyButton.layer.cornerRadius = 5.;
    self.buyButton.clipsToBounds = YES;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (IBAction)buySubscription:(id)sender {
    [self.delegate pushSubscriptionViewController];
}

@end
