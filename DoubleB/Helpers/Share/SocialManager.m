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

@interface SocialManager () <VKSdkDelegate>

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
    
    [VKSdk initializeWithDelegate:self andAppId:@"5055279"];
    
    return self;
}

#pragma mark - Facebook
- (void)shareFacebook {
    NSString *text = [DBShareHelper sharedInstance].textShare;
    NSDictionary *urls = [DBShareHelper sharedInstance].appUrls;
    text = [text stringByAppendingString:@" %@"];
    
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:urls[@"facebook"]];
    
    NSString *shareUrl = content.contentURL ?: urls[@"other"];
    text = [NSString stringWithFormat:text, shareUrl];
    content.contentDescription = text;
    content.imageURL = [NSURL URLWithString:[DBShareHelper sharedInstance].imageURL];
    
    [FBSDKShareDialog showFromViewController:self.delegate
                                 withContent:content
                                    delegate:nil];
}

#pragma mark - VK
- (void)shareVk {
    if ([VKSdk wakeUpSession]) {
        [self showVkShare];
    } else {
        [VKSdk authorize:@[VK_PER_PHOTOS, VK_PER_WALL] revokeAccess:YES];
    }
}

- (void)showVkShare {
    VKShareDialogController *shareDialog = [VKShareDialogController new];
    VKUploadImage *uploadImage = [[VKUploadImage alloc] init];
    uploadImage.sourceImage = [DBShareHelper sharedInstance].imageForShare;
    shareDialog.text = [DBShareHelper sharedInstance].textShare;
    shareDialog.uploadImages = @[uploadImage];
    shareDialog.shareLink    = [[VKShareLink alloc] initWithTitle:@"Super puper link, but nobody knows" link:[NSURL URLWithString:[DBShareHelper sharedInstance].appUrls[@"other"]]];
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

//#pragma mark - Facebook
//
//- (void)getFacebookUserInfo:(void(^)(BOOL success, NSDictionary *result))callback{
//    if([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded){
//        [self openSession:NO callback:^(BOOL success) {
//            if(success){
//                [self performRequestToFacebook:callback];
//            } else {
//                if(callback)
//                    callback(NO, nil);
//            }
//        }];
//    } else {
//        if([FBSession activeSession].state != FBSessionStateOpen && [FBSession activeSession].state != FBSessionStateOpenTokenExtended){
//            [self openSession:YES callback:^(BOOL success) {
//                if(success){
//                    [self performRequestToFacebook:callback];
//                } else {
//                    if(callback)
//                        callback(NO, nil);
//                }
//            }];
//        }
//    }
//}
//
//- (void)openSession:(BOOL)allowLoginUI callback:(void(^)(BOOL success))callback{
//    [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"user_birthday"]
//                                       allowLoginUI:allowLoginUI
//                                  completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
//                                      if(callback)
//                                          callback(error == nil);
//                                  }];
//}
//
//- (void)performRequestToFacebook:(void(^)(BOOL success, NSDictionary *result))callback{
//    NSMutableDictionary *resultResponse = [NSMutableDictionary new];
//    
//    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//        NSLog(@"%@", result);
//        
//        if(!error){
//            resultResponse[@"id"] = [result getValueForKey:@"id"] ?: @"";
//            resultResponse[@"first_name"] = [result getValueForKey:@"first_name"] ?: @"";
//            resultResponse[@"last_name"] = [result getValueForKey:@"last_name"] ?: @"";
////            resultResponse[@"birth_date"] = [result getValueForKey:@"birthday"] ?: @"";
//            
//            // Next request
//            NSDictionary *params = @{@"redirect": @NO,
//                                     @"height": @200,
//                                     @"width": @200,
//                                     @"type": @"normal"};
//            [FBRequestConnection startWithGraphPath:@"/me/picture" parameters:params HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//                NSLog(@"%@", result);
//                if(!error){
//                    resultResponse[@"image_url"] = [result[@"data"] getValueForKey:@"url"] ?: @"";
//                    if(callback)
//                        callback(YES, resultResponse);
//                } else {
//                    if(callback)
//                        callback(NO, nil);
//                }
//            }];
//        } else {
//            if(callback)
//                callback(NO, nil);
//        }
//    }];
//}

@end
