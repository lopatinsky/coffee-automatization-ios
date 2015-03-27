//
//  UIViewController+ShareExtension.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 12.01.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ShareExtension)

- (void)shareAppPermission:(void(^)(BOOL completed))callback;
- (void)shareSuccessfulOrder:(void(^)(BOOL completed))callback;

@end
