//
//  UIViewController+DBMessage.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 12.01.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface UIViewController (DBMessage)<MFMailComposeViewControllerDelegate>

- (void)presentMailViewControllerWithRecipients:(NSArray *)recipients callback:(void(^)(BOOL completed))callback;

@end
