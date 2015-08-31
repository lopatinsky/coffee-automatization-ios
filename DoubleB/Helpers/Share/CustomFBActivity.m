//
//  CustomFBActivity.m
//  
//
//  Created by Balaban Alexander on 31/08/15.
//
//

#import "CustomFBActivity.h"
#import "SocialManager.h"
#import <FacebookSDK/FacebookSDK.h>
#import <FBSDKShareLinkContent.h>
#import "FBSDKShareDialog.h"
#import "DBShareHelper.h"

@implementation CustomFBActivity

- (NSString *)activityType {
    return @"doubleb.empatika.sharefb";
}

- (NSString *)activityTitle {
    return @"Facebook";
}

- (UIImage *)activityImage {
    // Note: These images need to have a transparent background and I recommend these sizes:
    // iPadShare@2x should be 126 px, iPadShare should be 53 px, iPhoneShare@2x should be 100
    // px, and iPhoneShare should be 50 px. I found these sizes to work for what I was making.
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return [UIImage imageNamed:@"iPadShare.png"];
    }
    else
    {
        return [UIImage imageNamed:@"iPhoneShare.png"];
    }
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    NSLog(@"%s", __FUNCTION__);
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    NSLog(@"%s",__FUNCTION__);
}

- (UIViewController *)activityViewController {
    NSLog(@"%s",__FUNCTION__);
    return nil;
}

- (void)performActivity {
    [[SocialManager sharedInstance] getFacebookUserInfo:^(BOOL success, NSDictionary *result) {
        if (success) {
            NSString *text = [DBShareHelper sharedInstance].textShare;
//            UIImage *image = [DBShareHelper sharedInstance].imageForShare;
            
            NSDictionary *urls = [DBShareHelper sharedInstance].appUrls;
            text = [text stringByAppendingString:@" %@"];

            FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
            content.contentURL = [NSURL URLWithString:urls[@"facebook"]];
            
            NSString *shareUrl = content.contentURL ?: urls[@"other"];
            text = [NSString stringWithFormat:text, shareUrl];
            content.contentDescription = text;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [FBSDKShareDialog showFromViewController:self.delegate
                                             withContent:content
                                                delegate:nil];
                
            });
        }
    }];
}


@end
