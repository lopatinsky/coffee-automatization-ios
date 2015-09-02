//
//  SocialManager.m
//  SportsGround
//
//  Created by Ivan Oschepkov on 09.03.15.
//  Copyright (c) 2015 KondratovD. All rights reserved.
//

#import "SocialManager.h"
#import "DBShareHelper.h"

#import "MBProgressHUD.h"
#import <FacebookSDK/FacebookSDK.h>
#import <FBSDKShareLinkContent.h>
#import "FBSDKShareDialog.h"
#import "VKSdk.h"

#import "UIViewController+ShareExtension.h"

@interface SocialManager () <VKSdkDelegate, FBSDKSharingDelegate>

@property (nonatomic, strong) UIViewController<SocialManagerDelegate> *delegate;

@end

@implementation SocialManager

+ (instancetype)sharedManagerWithDelegate:(UIViewController<SocialManagerDelegate> *)delegate {
    static SocialManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SocialManager alloc] initWithDelegate:delegate];
    });
    return instance;
}

- (instancetype)initWithDelegate:(UIViewController<SocialManagerDelegate> *)delegate
{
    self = [super init];
    self.delegate = delegate;
    
    if ([[DBShareHelper sharedInstance].appUrls count] == 0) {
        [self.delegate socialManagerDidBeginFetchShareInfo];
        [[DBShareHelper sharedInstance] fetchShareInfo:^(BOOL success) {
            [self.delegate socialManagerDidEndFetchShareInfo];
        }];
    }
    
    // TODO: VKSDK appid from plist
    [VKSdk initializeWithDelegate:self andAppId:@"5055279"];
    
    return self;
}

#pragma mark - Facebook
- (void)shareFacebook {
    NSString *text = [DBShareHelper sharedInstance].textShare;
    NSDictionary *urls = [DBShareHelper sharedInstance].appUrls;
    text = [text stringByAppendingString:@". Или воспользуйте промокодом: %@"];
    
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:urls[@"facebook"]];
    
    text = [NSString stringWithFormat:text, [DBShareHelper sharedInstance].promoCode];
    content.contentDescription = text;
    content.contentTitle = [DBShareHelper sharedInstance].titleShareScreen;
    content.imageURL = [NSURL URLWithString:[DBShareHelper sharedInstance].imageURL];
    
    [FBSDKShareDialog showFromViewController:self.delegate
                                 withContent:content
                                    delegate:self];
}

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    NSLog(@"%@", results);
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    NSLog(@"canceled");
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
    text = [text stringByAppendingString:@". Или воспользуйте промокодом: %@"];
    shareDialog.text = [NSString stringWithFormat:text, [DBShareHelper sharedInstance].promoCode];
    shareDialog.uploadImages = @[uploadImage];
    shareDialog.shareLink    = [[VKShareLink alloc] initWithTitle:@"Приглашение для друга" link:[NSURL URLWithString:[DBShareHelper sharedInstance].appUrls[@"other"]]];
    [shareDialog setCompletionHandler:^(VKShareDialogControllerResult result) {
        [self.delegate dismissViewControllerAnimated:YES completion:nil];
    }];
    [self.delegate presentViewController:shareDialog animated:YES completion:nil];
}

#pragma mark - Other
- (void)shareOther:(NSString *)screen {
    [self.delegate sharePermissionOnScreen:screen callback:^(BOOL completed) {
        if (completed) {
            [self.delegate dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

#pragma mark - VK SDK delegate
- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken {
    [self showVkShare];
}

- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError {
    
}

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    VKCaptchaViewController *captchaVC = [VKCaptchaViewController captchaControllerWithError:captchaError];
    [captchaVC presentIn:self.delegate];
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    [self.delegate presentViewController:controller animated:YES completion:nil];
}

@end
