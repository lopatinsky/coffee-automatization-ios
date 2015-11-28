//
//  DBGiftBarButtonView.m
//  DoubleB
//
//  Created by Balaban Alexander on 29/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBGiftBarButtonView.h"
#import "DBFriendGiftHelper.h"

@implementation DBGiftBarButtonView

- (instancetype)init{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBGiftBarButtonView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib{
    self.backgroundColor = [UIColor clearColor];
    
    [self.orderImageView templateImageWithName:@"shopping_cart_icon.png" tintColor:[UIColor whiteColor]];
    
    self.countLabel.layer.cornerRadius = self.countLabel.frame.size.height / 2;
    self.countLabel.layer.masksToBounds = YES;
    
    self.countLabel.textColor = [UIColor whiteColor];
    
    [[DBFriendGiftHelper sharedInstance] addObserver:self withKeyPath:DBFriendGiftHelperNotificationItemsPrice selector:@selector(reload)];
    [self reload];
}

- (void)dealloc {
    [[DBFriendGiftHelper sharedInstance] removeObserver:self];
}

- (void)reload {
    NSInteger count = [DBFriendGiftHelper sharedInstance].itemsManager.totalCount;
    if (count == 0) {
        self.countLabel.hidden = YES;
    } else {
        self.countLabel.hidden = NO;
        self.countLabel.text = [NSString stringWithFormat:@"%ld", (long)count];
    }
}

@end
