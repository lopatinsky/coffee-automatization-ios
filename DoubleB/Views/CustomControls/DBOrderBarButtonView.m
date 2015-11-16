//
//  DBOrderBarButtonView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 17.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBOrderBarButtonView.h"
#import "OrderCoordinator.h"

@implementation DBOrderBarButtonView

- (instancetype)init{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBOrderBarButtonView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib{
    self.backgroundColor = [UIColor clearColor];
    
    [self.orderImageView templateImageWithName:@"shopping_cart_icon.png" tintColor:[UIColor whiteColor]];
    
    self.countLabel.layer.cornerRadius = self.countLabel.frame.size.height / 2;
    self.countLabel.layer.masksToBounds = YES;
    
    self.countLabel.textColor = [UIColor whiteColor];
    
    [[OrderCoordinator sharedInstance] addObserver:self withKeyPaths:@[CoordinatorNotificationOrderItemsTotalCount] selector:@selector(reload)];
    [self reload];
}

-(void)dealloc{
    [[OrderCoordinator sharedInstance] removeObserver:self];
}

- (void)reload {
    NSInteger count = [OrderCoordinator sharedInstance].itemsManager.totalCount;
    if (count == 0) {
        self.countLabel.hidden = YES;
    } else {
        self.countLabel.hidden = NO;
        self.countLabel.text = [NSString stringWithFormat:@"%ld", (long)count];
    }
}

@end
