//
//  UIViewController+DBCardManagement.h
//  DoubleB
//
//  Created by Ощепков Иван on 13.02.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBProfileViewController.h"

@interface UIViewController (DBCardManagement)<DBProfileViewControllerDelegate>

// Screen - Google Analytics screen identifier
- (void)db_cardManagementBindNewCardOnScreen:(NSString *)screen
                                    callback:(void(^)(BOOL success))completionHandler;

@end
