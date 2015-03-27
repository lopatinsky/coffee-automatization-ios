//
// Created by Sergey Pronin on 6/21/14.
// Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Position;


/**
* Fetches and stores menu in Data object
*/
@interface MenuHelper : NSObject

@property (nonatomic, strong) NSArray *fetchedMenu;

+ (instancetype)sharedHelper;

/**
* 'Get' - local
* Then perform 'fetch' and cache the result
* If cached menu is available completionHandler will be called twice:
*   1 - for cached menu
*   2 - for fetched menu
* @returns if cached object available
*/
- (BOOL)getMenuForVenue:(NSString *)venueId completionHandler:(void(^)(id response))completionHandler;

/**
* 'Fetch' - remote
* completionHandler will be called only once for fetched menu
*/
- (void)fetchMenuWithCompletionHandler:(void(^)(BOOL success, id result))completionHandler;
/**
 * 'Fetch' - remote
 * Try to configure buttons on preview
 */
//- (void)fetchMenuAndGetPreviewFlag:(void(^)(BOOL shouldShowSkipButton, NSError *error))completionHandler;

/**
* Find specific position in cached menu
*/
//- (Position *)findPositionWithId:(NSString *)itemId;
//- (Position *)findPositionWithName:(NSString *)itemName;
- (NSDictionary *)fetchNameAndExtFromPositionName:(NSString *)name price:(NSNumber *)price;

@end