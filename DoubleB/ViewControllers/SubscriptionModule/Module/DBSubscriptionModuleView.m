//
//  DBSubscriptionModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 14/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBSubscriptionModuleView.h"

@interface DBSubscriptionModuleView ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *buyView;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UILabel *buyLabel;

@end

@implementation DBSubscriptionModuleView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBSubscriptionModuleView" owner:self options:nil] firstObject];
    
    return self;
}
- (void)awakeFromNib {
    
}

@end
