//
//  SocialManager.h
//  SportsGround
//
//  Created by Ivan Oschepkov on 09.03.15.
//  Copyright (c) 2015 KondratovD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SocialManager : NSObject

+ (instancetype)sharedInstance;

- (void)getFacebookUserInfo:(void(^)(BOOL success, NSDictionary *result))callback;

@end
