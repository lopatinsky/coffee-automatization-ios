//
//  UIViewController+AlertView.h
//  SportsGround
//
//  Created by Ivan Oschepkov on 11.04.15.
//  Copyright (c) 2015 KondratovD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (AlertView)
- (void)showError:(NSString *)message;
- (void)showAlert:(NSString *)message;
@end
