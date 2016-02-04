//
//  SocialManager.h
//  SportsGround
//
//  Created by Ivan Oschepkov on 09.03.15.
//  Copyright (c) 2015 KondratovD. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DBSocialManagerDelegate <NSObject>
- (UIViewController*)db_socialManagerContainer;
@end

@interface SocialManager : NSObject
@property (nonatomic) id<DBSocialManagerDelegate> delegate;
+ (instancetype)sharedManager;

- (BOOL)vkIsAvailable;

- (void)shareFacebook;
- (void)shareVk;
- (void)shareMessage:(UIViewController *)vc;
- (void)shareOther:(NSString *)screen;

@end
