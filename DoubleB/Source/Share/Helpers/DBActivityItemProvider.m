//
//  DBActivityItemProvider.m
//  DoubleB
//
//  Created by Ощепков Иван on 05.03.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBActivityItemProvider.h"
#import "DBCompanyInfo.h"

NSString *const DBActivityTypePostToVK = @"com.vk.vkclient.shareextension";
NSString *const DBActivityTypePostToWhatsApp = @"net.whatsapp.WhatsApp.ShareExtension";

@interface DBActivityItemProvider ()
@property(strong, nonatomic) NSString *textFormat;
@property(strong, nonatomic) NSDictionary *links;
@end

@implementation DBActivityItemProvider

- (instancetype)initWithTextFormat:(NSString *)textFormat links:(NSDictionary *)links{
    self = [super initWithPlaceholderItem:@"Doubleb"];
    
    self.textFormat = textFormat;
    self.links = links;
    
    return self;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    
    NSString *shareUrl;
    if ([activityType isEqualToString:UIActivityTypePostToFacebook]) {
        shareUrl = self.links[@"facebook"];
    }
    
    if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
        shareUrl = self.links[@"twitter"];
    }
    
    if ([activityType isEqualToString:UIActivityTypeMessage]) {
        shareUrl = self.links[@"sms"];
    }
    
    if ([activityType isEqualToString:UIActivityTypeMail]) {
        shareUrl = self.links[@"email"];
    }
    
    if ([activityType isEqualToString:DBActivityTypePostToVK]) {
        shareUrl = self.links[@"vk"];
    }
    
    if ([activityType isEqualToString:DBActivityTypePostToWhatsApp]) {
        shareUrl = self.links[@"whatsApp"];
    }
    
    shareUrl = shareUrl ?: self.links[@"other"];
    NSString *text = [NSString stringWithFormat:self.textFormat, shareUrl];
    
    return text;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType {
    if ([activityType isEqualToString:UIActivityTypeMail]) {
        return [DBCompanyInfo sharedInstance].applicationName;
    } else {
        return nil;
    }
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    return @"Doubleb";
}
@end
