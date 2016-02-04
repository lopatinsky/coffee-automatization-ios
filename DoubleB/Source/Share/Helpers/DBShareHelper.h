//
//  DBShareHelper.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 19.01.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBModuleManagerProtocol.h"

@interface DBShareHelper : DBPrimaryManager<DBModuleManagerProtocol>
@property(nonatomic) BOOL enabled;
@property(nonatomic) BOOL infoLoaded;

@property(strong, nonatomic, readonly) UIImage *imageForShare;
@property(strong, nonatomic) NSString *imageURL;
@property(strong, nonatomic, readonly) NSDictionary *appUrls;
@property(strong, nonatomic, readonly) NSString *textShare;

@property(strong, nonatomic, readonly) NSString *titleShareScreen;
@property(strong, nonatomic, readonly) NSString *textShareScreen;
@property(strong, nonatomic, readonly) NSString *promoCode;

- (void)fetchShareInfo:(void(^)(BOOL success))callback;

// Small view on bottom of screen for share permission
@property (nonatomic) BOOL shareSuggestionIsAvailable;
- (void)showShareSuggestion:(BOOL)animated;

@end
