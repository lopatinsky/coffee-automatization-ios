//
//  DBProfileBarButtonItem.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 05/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBProfileBarButtonItem.h"

@interface DBProfileBarButtonItem ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@end

@implementation DBProfileBarButtonItem

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBProfileBarButtonItem" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    [self.iconImageView templateImageWithName:@"profile_bar_icon.png" tintColor:[UIColor whiteColor]];
}

@end
