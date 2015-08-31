 //
//  UIViewController+ShareExtension.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 12.01.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "UIViewController+ShareExtension.h"
#import "Compatibility.h"
#import "DBShareHelper.h"
#import "MBProgressHUD.h"
#import "DBActivityItemProvider.h"
#import "CustomFBActivity.h"

@implementation UIViewController (ShareExtension)

static NSString *dbAnaliticsNameScreenName;

- (void)sharePermissionOnScreen:(NSString *)analiticsScreenName callback:(void(^)(BOOL completed))callback{
    dbAnaliticsNameScreenName = analiticsScreenName;
    
    if ([[DBShareHelper sharedInstance].appUrls count] > 0) {
        NSString *text = [DBShareHelper sharedInstance].textShare;
        UIImage *image = [DBShareHelper sharedInstance].imageForShare;
        NSDictionary *urls = [DBShareHelper sharedInstance].appUrls;
        text = [text stringByAppendingString:@" %@"];
        
        DBActivityItemProvider *customActivityProvider = [[DBActivityItemProvider alloc] initWithTextFormat:text
                                                                                                      links:urls
                                                                                                      image:image];
        
        [self shareWithActivityItems:@[customActivityProvider, image] withCallback:callback];
    } else {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[DBShareHelper sharedInstance] fetchShareInfo:^(BOOL success) {
            if(success){
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                
                NSString *text = [DBShareHelper sharedInstance].textShare;
                UIImage *image = [DBShareHelper sharedInstance].imageForShare;
                NSDictionary *urls = [DBShareHelper sharedInstance].appUrls;
                text = [text stringByAppendingString:@" %@"];
                
                if([DBShareHelper sharedInstance].appUrls && [[DBShareHelper sharedInstance].appUrls count] > 0){
                    DBActivityItemProvider *customActivityProvider = [[DBActivityItemProvider alloc] initWithTextFormat:text
                                                                                                                  links:urls
                                                                                                                  image:image];
                    [self shareWithActivityItems:@[customActivityProvider, image] withCallback:callback];
                } else {
                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Ошибка", nil)
                                                message:NSLocalizedString(@"NoInternetConnectionErrorMessage", nil)
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                }
            }
        }];
    }
}

- (void)shareWithActivityItems:(NSArray *)activityItems withCallback:(void(^)(BOOL completed))callback{
    CustomFBActivity *customActivity = [[CustomFBActivity alloc] init];
    customActivity.delegate = self;
    UIActivityViewController *shareVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                                                          applicationActivities:@[customActivity]];
    shareVC.excludedActivityTypes = @[UIActivityTypeAirDrop,
                                      UIActivityTypePrint,
                                      UIActivityTypeAssignToContact,
                                      UIActivityTypeCopyToPasteboard,
                                      UIActivityTypeSaveToCameraRoll,
                                      UIActivityTypeAddToReadingList,
                                      UIActivityTypePostToFlickr,
                                      UIActivityTypePostToVimeo,
                                      UIActivityTypePostToFacebook
                                    ];
    
    
    if([Compatibility systemVersionGreaterOrEqualThan:@"8.0"]){
        shareVC.completionWithItemsHandler = ^void(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError){
            if(completed){
                [GANHelper analyzeEvent:@"share_success" label:activityType category:dbAnaliticsNameScreenName];
            } else {
                if(activityError == nil){
                    if(activityType){
                        [GANHelper analyzeEvent:@"share_dialog_cancelled" label:activityType category:dbAnaliticsNameScreenName];
                    } else {
                        [GANHelper analyzeEvent:@"share_cancelled" category:dbAnaliticsNameScreenName];
                    }
                } else {
                    [GANHelper analyzeEvent:@"share_failure"
                                      label:[NSString stringWithFormat:@"%@, %@", activityType, activityError.description]
                                   category:dbAnaliticsNameScreenName];
                }
            }
            if(callback)
                callback(completed);
        };
    } else {
        shareVC.completionHandler = ^void(NSString *activityType, BOOL completed){
            if(completed){
                [GANHelper analyzeEvent:@"share_success" label:activityType category:dbAnaliticsNameScreenName];
            } else {
                if(activityType){
                    [GANHelper analyzeEvent:@"share_dialog_cancelled" label:activityType category:dbAnaliticsNameScreenName];
                } else {
                    [GANHelper analyzeEvent:@"share_cancelled" category:dbAnaliticsNameScreenName];
                }
            }
            
            if(callback)
                callback(completed);
        };
    }
    
    [self presentViewController:shareVC animated:YES completion:nil];
}

@end
