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
@property(strong, nonatomic, readonly) NSDictionary *appUrls;
@property(strong, nonatomic, readonly) NSString *textShare;

@property(strong, nonatomic, readonly) NSString *titleShareScreen;
@property(strong, nonatomic, readonly) NSString *textShareScreen;

+ (instancetype)sharedInstance;

- (void)fetchShareSupportInfo;
- (void)fetchShareInfo:(void(^)(BOOL success))callback;


@end
