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

@implementation UIViewController (ShareExtension)

static NSString *screenName;

- (void)shareAppPermission:(void(^)(BOOL completed))callback{
    screenName = @"Settings_screen";
    
    NSString *text = [DBShareHelper sharedInstance].textShareAboutApp;
    NSURL *url = [NSURL URLWithString:[DBShareHelper sharedInstance].appUrlForSettings];
    UIImage *image = [DBShareHelper sharedInstance].imageForShare;
    
    [self shareText:text url:url image:image withCallback:callback];
}

- (void)shareSuccessfulOrder:(void(^)(BOOL completed))callback{
    screenName = @"Share_permission_screen";
    
    NSString *text = [DBShareHelper sharedInstance].textShareNewOrder;
    NSURL *url = [NSURL URLWithString:[DBShareHelper sharedInstance].appUrl];
    UIImage *image = [DBShareHelper sharedInstance].imageForShare;
    
    [self shareText:text url:url image:image withCallback:callback];
}

- (void)shareText:(NSString *)text url:(NSURL *)url image:(UIImage *)image withCallback:(void(^)(BOOL completed))callback{
    NSMutableArray *activityItems = [[NSMutableArray alloc] init];
    if(text){
        [activityItems addObject:text];
        [activityItems addObject:@"\n\n"];
    }
    if(url){
        [activityItems addObject:url];
    }
    if(image){
        [activityItems addObject:image];
    }
    
    [activityItems addObject:@"\n\n"];
    [activityItems addObject:NSLocalizedString(@"Даблби", nil)];
    
    UIActivityViewController *shareVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                                                          applicationActivities:nil];
    shareVC.excludedActivityTypes = @[UIActivityTypeAirDrop,
                                      UIActivityTypePrint,
                                      UIActivityTypeAssignToContact,
                                      UIActivityTypeCopyToPasteboard,
                                      UIActivityTypeSaveToCameraRoll,
                                      UIActivityTypeAddToReadingList,
                                      UIActivityTypePostToFlickr,
                                      UIActivityTypePostToVimeo];
    
    
    if([Compatibility systemVersionGreaterOrEqualThan:@"8.0"]){
        shareVC.completionWithItemsHandler = ^void(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError){
            if(completed){
            } else {
                if(activityError == nil){
                    if(activityType){
                    } else {
                    }
                } else {
                }
            }
            if(callback)
                callback(completed);
        };
    } else {
        shareVC.completionHandler = ^void(NSString *activityType, BOOL completed){
            if(completed){
            } else {
                if(activityType){
                } else {
                }
            }
            
            if(callback)
                callback(completed);
        };
    }
    
    [self presentViewController:shareVC animated:YES completion:nil];
}

@end
