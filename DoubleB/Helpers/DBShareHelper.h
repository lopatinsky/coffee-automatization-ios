//
//  DBShareHelper.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 19.01.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBShareHelper : NSObject

@property(strong, nonatomic, readonly) UIImage *imageForShare;
@property(strong, nonatomic, readonly) NSString *appUrl;
@property(strong, nonatomic, readonly) NSString *appUrlForSettings;
@property(strong, nonatomic, readonly) NSString *textShareNewOrder;
@property(strong, nonatomic, readonly) NSString *textShareAboutApp;

@property(strong, nonatomic, readonly) NSString *titleShareScreen;
@property(strong, nonatomic, readonly) NSString *textShareScreen;

+ (instancetype)sharedInstance;

- (void)updateShareInfo;
@end
