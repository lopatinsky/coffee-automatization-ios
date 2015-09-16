 //
//  UIViewController+ShareExtension.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 12.01.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "UIAlertView+BlocksKit.h"
#import "UIViewController+ShareExtension.h"
#import "DBShareHelper.h"
#import "MBProgressHUD.h"
#import "DBActivityItemProvider.h"

@implementation UIViewController (ShareExtension)

static NSString *dbAnaliticsNameScreenName;

- (void)sharePermissionOnScreen:(NSString *)analiticsScreenName callback:(void(^)(BOOL completed))callback{
    dbAnaliticsNameScreenName = analiticsScreenName;
    
    NSString *text = [DBShareHelper sharedInstance].textShare;
    UIImage *image = [DBShareHelper sharedInstance].imageForShare;
    NSDictionary *urls = [DBShareHelper sharedInstance].appUrls;
    text = [text stringByAppendingString:@" %@"];
    
    if ([[DBShareHelper sharedInstance].appUrls count] > 0) {
        NSMutableArray *activityItems = [NSMutableArray new];
        [activityItems addObject:[[DBActivityItemProvider alloc] initWithTextFormat:text links:urls]];
        
        if(image)
            [activityItems addObject:image];
        
        [self shareWithActivityItems:activityItems withCallback:callback];
    } else {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[DBShareHelper sharedInstance] fetchShareInfo:^(BOOL success) {
            if(success){
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                
                if([DBShareHelper sharedInstance].appUrls && [[DBShareHelper sharedInstance].appUrls count] > 0){
                    NSMutableArray *activityItems = [NSMutableArray new];
                    [activityItems addObject:[[DBActivityItemProvider alloc] initWithTextFormat:text links:urls]];
                    
                    if(image)
                        [activityItems addObject:image];
                    
                    [self shareWithActivityItems:activityItems withCallback:callback];
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
    UIActivityViewController *shareVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                                                          applicationActivities:nil];
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
                [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Успешно!", nil) message:@"" cancelButtonTitle:@"OK" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {}];
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
                    
                    [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Ошибка!", nil) message:@"" cancelButtonTitle:@"OK" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        
                    }];
                }
            }
            if(callback)
                callback(completed);
        };
    } else {
        shareVC.completionHandler = ^void(NSString *activityType, BOOL completed){
            if(completed){
                [GANHelper analyzeEvent:@"share_success" label:activityType category:dbAnaliticsNameScreenName];
                [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Успешно!", nil) message:@"" cancelButtonTitle:@"OK" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {}];
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
