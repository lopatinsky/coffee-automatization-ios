//
//  SocialManager.m
//  SportsGround
//
//  Created by Ivan Oschepkov on 09.03.15.
//  Copyright (c) 2015 KondratovD. All rights reserved.
//

#import "SocialManager.h"
#import "DBShareHelper.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "VKSdk.h"

#import "UIAlertView+BlocksKit.h"
#import "UIViewController+ShareExtension.h"

#import <MessageUI/MessageUI.h>

@interface SocialManager () <MFMessageComposeViewControllerDelegate, VKSdkDelegate, FBSDKSharingDelegate>

@end

@implementation SocialManager

+ (instancetype)sharedManager {
    static SocialManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SocialManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];

    [VKSdk initializeWithDelegate:self andAppId:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"VKAppId"] ?: @""];
    
    return self;
}

- (BOOL)vkIsAvailable {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"VKAppId"] != nil;
}

- (void)shareDidFail {
    [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Ошибка!", nil) message:@"" cancelButtonTitle:@"OK" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
    }];
}

- (void)shareDidSuccess {
    [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Успешно!", nil) message:@"" cancelButtonTitle:@"OK" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
    }];
}

#pragma mark - Facebook
- (void)shareFacebook {
    NSString *text = [DBShareHelper sharedInstance].textShare;
    NSDictionary *urls = [DBShareHelper sharedInstance].appUrls;
    text = [NSString stringWithFormat:@"%@\nИли воспользуйтесь промокодом: %@", text, [DBShareHelper sharedInstance].promoCode];
    
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:urls[@"facebook"]];
    content.contentDescription = text;
    content.contentTitle = [DBShareHelper sharedInstance].titleShareScreen;
    content.imageURL = [NSURL URLWithString:[DBShareHelper sharedInstance].imageURL];

    
    FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
    if ([self.delegate respondsToSelector:@selector(db_socialManagerContainer)]) {
        dialog.fromViewController = [self.delegate db_socialManagerContainer];
    }
    
    dialog.shareContent = content;
    dialog.delegate = self;
    dialog.mode = FBSDKShareDialogModeNative;
    if (![dialog canShow]) {
        dialog.mode = FBSDKShareDialogModeFeedBrowser;
    }
    [dialog show];
    
    // Track if share correct
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]]) {
        [GANHelper analyzeEvent:@"facebook_share" label:@"app" category:SHARE_PERMISSION_SCREEN];
    } else {
        [GANHelper analyzeEvent:@"facebook_share" label:@"external" category:SHARE_PERMISSION_SCREEN];
    }
}

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    [GANHelper analyzeEvent:@"share_success" label:@"facebook" category:SHARE_PERMISSION_SCREEN];
    [self shareDidSuccess];
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    [GANHelper analyzeEvent:@"share_failure"
                      label:[NSString stringWithFormat:@"facebook, %@", error.description]
                   category:SHARE_PERMISSION_SCREEN];
    [self shareDidFail];
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    [GANHelper analyzeEvent:@"share_dialog_cancelled" label:@"facebook" category:SHARE_PERMISSION_SCREEN];
}

#pragma mark - VK
- (void)shareVk {
    if ([VKSdk wakeUpSession]) {
        [self showVkShare];
    } else {
        [VKSdk authorize:@[VK_PER_PHOTOS, VK_PER_WALL] revokeAccess:YES];
    }
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
    [VKSdk authorize:@[VK_PER_PHOTOS, VK_PER_WALL] revokeAccess:YES];
}

- (void)showVkShare {
    VKShareDialogController *shareDialog = [VKShareDialogController new];
    VKUploadImage *uploadImage = [[VKUploadImage alloc] init];
    uploadImage.sourceImage = [DBShareHelper sharedInstance].imageForShare;
    
    NSString *text = [DBShareHelper sharedInstance].textShare;
    text = [text stringByAppendingString:@"\nИли воспользуйтесь промокодом: %@"];
    shareDialog.text = [NSString stringWithFormat:text, [DBShareHelper sharedInstance].promoCode];
    shareDialog.uploadImages = @[uploadImage];
    shareDialog.shareLink    = [[VKShareLink alloc] initWithTitle:@"Приглашение для друга" link:[NSURL URLWithString:[DBShareHelper sharedInstance].appUrls[@"vk"]]];
    
    [shareDialog setCompletionHandler:^(VKShareDialogControllerResult result) {
        if (result == VKShareDialogControllerResultDone) {
            [GANHelper analyzeEvent:@"share_success" label:@"vk" category:SHARE_PERMISSION_SCREEN];
            [self shareDidSuccess];
        } else {
            [GANHelper analyzeEvent:@"share_dialog_cancelled" label:@"vk" category:SHARE_PERMISSION_SCREEN];
        }
        [[self.delegate db_socialManagerContainer] dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [[self.delegate db_socialManagerContainer] presentViewController:shareDialog animated:YES completion:nil];
}

- (void)shareMessage:(UIViewController *)vc {
    NSString *text = [DBShareHelper sharedInstance].textShare;
    text = [text stringByAppendingString:@"\n%@\nИли воспользуйтесь промокодом: %@"];
    NSDictionary *urls = [DBShareHelper sharedInstance].appUrls;
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.view.tintColor = vc.view.tintColor;
    messageController.messageComposeDelegate = self;
    messageController.body = [NSString stringWithFormat:text, [NSURL URLWithString:urls[@"sms"]], [DBShareHelper sharedInstance].promoCode];
    [vc presentViewController:messageController animated:YES completion:nil];
}

#pragma mark - MFMessageViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - Other
- (void)shareOther:(NSString *)screen {
    if ([self.delegate respondsToSelector:@selector(db_socialManagerContainer)]) {
        [[self.delegate db_socialManagerContainer] sharePermissionOnScreen:screen callback:^(BOOL completed) {
            if (completed) {
                [[self.delegate db_socialManagerContainer] dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
}

#pragma mark - VK SDK delegate
- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken {
    [self showVkShare];
}

- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError {
    
}

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    VKCaptchaViewController *captchaVC = [VKCaptchaViewController captchaControllerWithError:captchaError];
    [captchaVC presentIn:[self.delegate db_socialManagerContainer]];
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    [[self.delegate db_socialManagerContainer] presentViewController:controller animated:YES completion:nil];
}

@end
