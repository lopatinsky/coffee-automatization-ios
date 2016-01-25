//
//  UIViewController+DBMessage.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 12.01.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "UIViewController+DBMessage.h"
#import "DBCompanyInfo.h"
#import "DBAPIClient.h"

@implementation UIViewController (DBMessage)

static void (^dbMailViewControllerCallBack)(BOOL completed);
static void (^dbMessageViewControllerCallBack)(MessageComposeResult result);

- (void)presentMailViewControllerWithRecipients:(NSArray *)recipients callback:(void(^)(BOOL completed))callback{
    NSMutableArray *emails = [NSMutableArray arrayWithArray:[[DBCompanyInfo sharedInstance] supportEmails]];
    [emails addObject:[self getCompanySupportMail]];
    if([MFMailComposeViewController canSendMail]){
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        [mailer setSubject:[ApplicationConfig db_bundleName]];
        [mailer setToRecipients:emails];
        if(recipients)
            [mailer setToRecipients:recipients];
        [mailer setMailComposeDelegate:self];
        
        mailer.navigationBar.tintColor = [UIColor whiteColor];
        
        dbMailViewControllerCallBack = callback;
        [self presentViewController:mailer animated:YES completion:nil];
    } else {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Ошибка", nil)
                                    message:NSLocalizedString(@"Для отправки сообщений необходима авторизация в Mail", nil)
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                          otherButtonTitles:nil] show];
    }
    
}

- (NSString *)getCompanySupportMail {
    NSString *companyURL = [DBAPIClient baseUrl];
    NSString *namespace = [companyURL componentsSeparatedByString:@"."][0];
    namespace = [namespace stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    
    NSMutableString *companyMail = [NSMutableString new];
    [companyMail appendString:@"support+"];
    [companyMail appendString:namespace];
    [companyMail appendString:@"@ru-beacon.ru"];
    return companyMail;
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail sending Cancelled");
            break;
        case MFMailComposeResultFailed:
            [[[UIAlertView alloc] initWithTitle:@"Ошибка"
                                        message:@"Произошла непредвиденная ошибка при отправке сообщения"
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            break;
        case MFMailComposeResultSent:
            break;
        default:
            break;
    }
    
    if(dbMailViewControllerCallBack){
        if(result == MFMailComposeResultSent){
            dbMailViewControllerCallBack(YES);
        } else {
            dbMailViewControllerCallBack(NO);
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)presentMessageViewControllerWithText:(NSString *)text
                                  recipients:(NSArray *)recipients
                                    callback:(void(^)(MessageComposeResult result))callback{
    if([MFMessageComposeViewController canSendText]){
        dbMessageViewControllerCallBack = callback;
        MFMessageComposeViewController *messenger = [[MFMessageComposeViewController alloc] init];
        messenger.body = text;
        messenger.recipients = recipients;
        messenger.messageComposeDelegate = self;
        messenger.navigationBar.tintColor = [UIColor whiteColor];
        
        [self.navigationController presentViewController:messenger animated:YES completion:nil];
    } else {
        dbMessageViewControllerCallBack = nil;
        [[[UIAlertView alloc] initWithTitle:@"Ошибка"
                                    message:@"Вы не можете посылать SMS-сообщения с этого устройства"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    switch (result) {
        case MessageComposeResultCancelled:
            NSLog(@"Message sending Cancelled");
            break;
        case MessageComposeResultFailed:
            [[[UIAlertView alloc] initWithTitle:@"Ошибка"
                                        message:@"Произошла непредвиденная ошибка при отправке сообщения"
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            break;
        case MessageComposeResultSent:
            break;
        default:
            break;
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    if(dbMessageViewControllerCallBack){
        dbMessageViewControllerCallBack(result);
    }
}

@end
