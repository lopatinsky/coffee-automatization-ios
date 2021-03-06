//
//  UIViewController+AlertView.m
//  SportsGround
//
//  Created by Ivan Oschepkov on 11.04.15.
//  Copyright (c) 2015 KondratovD. All rights reserved.
//

#import "UIViewController+AlertView.h"

@implementation UIViewController (AlertView)

- (void)showError:(NSString *)message{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Ошибка", nil)
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

- (void)showAlert:(NSString *)message{
    [self showAlert:@"" message:message];
}

- (void)showAlert:(NSString *)title message:(NSString *)message {
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

@end
