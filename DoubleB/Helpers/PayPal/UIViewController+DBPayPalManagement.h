//
//  UIViewController+DBPayPalManagement.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 20.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBPayPalManager.h"

@interface UIViewController (DBPayPalManagement)<DBPayPalManagerDelegate>

- (void)bindPayPal:(void(^)(BOOL success))callback;
- (void)unbindPayPal:(void(^)(BOOL success))callback;

@end
