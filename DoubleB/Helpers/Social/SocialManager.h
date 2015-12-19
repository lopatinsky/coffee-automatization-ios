//
//  SocialManager.h
//  SportsGround
//
//  Created by Ivan Oschepkov on 09.03.15.
//  Copyright (c) 2015 KondratovD. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SocialManagerDelegate <NSObject>

- (void)socialManagerDidBeginFetchShareInfo;
- (void)socialManagerDidEndFetchShareInfo;

@end

@interface SocialManager : NSObject

+ (instancetype)sharedManagerWithDelegate:(UIViewController<SocialManagerDelegate> *)delegate;

- (void)shareFacebook;
//- (void)shareVk;
- (void)shareMessage:(UIViewController *)vc;
- (void)shareOther:(NSString *)screen;

@end
