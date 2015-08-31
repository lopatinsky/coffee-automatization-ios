//
//  SocialManager.m
//  SportsGround
//
//  Created by Ivan Oschepkov on 09.03.15.
//  Copyright (c) 2015 KondratovD. All rights reserved.
//

#import "SocialManager.h"
#import <FacebookSDK/FacebookSDK.h>

@interface SocialManager ()
@end

@implementation SocialManager

+ (instancetype)sharedInstance
{
    static SocialManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [SocialManager new];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    
    return self;
}

#pragma mark - Facebook

- (void)getFacebookUserInfo:(void(^)(BOOL success, NSDictionary *result))callback{
    if([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded){
        [self openSession:NO callback:^(BOOL success) {
            if(success){
                [self performRequestToFacebook:callback];
            } else {
                if(callback)
                    callback(NO, nil);
            }
        }];
    } else {
        if([FBSession activeSession].state != FBSessionStateOpen && [FBSession activeSession].state != FBSessionStateOpenTokenExtended){
            [self openSession:YES callback:^(BOOL success) {
                if(success){
                    [self performRequestToFacebook:callback];
                } else {
                    if(callback)
                        callback(NO, nil);
                }
            }];
        }
    }
}

- (void)openSession:(BOOL)allowLoginUI callback:(void(^)(BOOL success))callback{
    [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"user_birthday"]
                                       allowLoginUI:allowLoginUI
                                  completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                      if(callback)
                                          callback(error == nil);
                                  }];
}

- (void)performRequestToFacebook:(void(^)(BOOL success, NSDictionary *result))callback{
    NSMutableDictionary *resultResponse = [NSMutableDictionary new];
    
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSLog(@"%@", result);
        
        if(!error){
            resultResponse[@"id"] = [result getValueForKey:@"id"] ?: @"";
            resultResponse[@"first_name"] = [result getValueForKey:@"first_name"] ?: @"";
            resultResponse[@"last_name"] = [result getValueForKey:@"last_name"] ?: @"";
//            resultResponse[@"birth_date"] = [result getValueForKey:@"birthday"] ?: @"";
            
            // Next request
            NSDictionary *params = @{@"redirect": @NO,
                                     @"height": @200,
                                     @"width": @200,
                                     @"type": @"normal"};
            [FBRequestConnection startWithGraphPath:@"/me/picture" parameters:params HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                NSLog(@"%@", result);
                if(!error){
                    resultResponse[@"image_url"] = [result[@"data"] getValueForKey:@"url"] ?: @"";
                    if(callback)
                        callback(YES, resultResponse);
                } else {
                    if(callback)
                        callback(NO, nil);
                }
            }];
        } else {
            if(callback)
                callback(NO, nil);
        }
    }];
}

@end
