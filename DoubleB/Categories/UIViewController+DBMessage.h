//
//  UIViewController+DBMessage.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 12.01.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface UIViewController (DBMessage)<MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

- (void)presentMailViewControllerWithRecipients:(NSArray *)recipients
                                       callback:(void(^)(BOOL completed))callback;

- (void)presentMessageViewControllerWithText:(NSString *)text
                                  recipients:(NSArray *)recipients
                                    callback:(void(^)(MessageComposeResult result))callback;
@end
