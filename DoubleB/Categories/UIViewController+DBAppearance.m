//
//  UIViewController+DBAppearance.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 05.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "UIViewController+DBAppearance.h"

@implementation UIViewController (DBAppearance)

- (void)db_setTitle:(NSString *)title {
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 44)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"Helvetica Light" size:17];
    titleLabel.numberOfLines = 2;
    titleLabel.text = title;
    
    [self.navigationItem setTitleView:titleLabel];
}

@end
