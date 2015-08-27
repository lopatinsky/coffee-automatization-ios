//
//  UIViewController+DBAppearance.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 05.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (DBAppearance)

+ (UIViewController *)currentViewController;

- (void)db_setTitle:(NSString *)title;

@end
