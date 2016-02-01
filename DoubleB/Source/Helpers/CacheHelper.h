//
//  CacheHelper.h
//  PromoteEducate-ios
//
//  Created by Sergey Pronin on 05/18/13.
//  Copyright (c) 2013 Sergey Pronin. All rights reserved.
//


/**
* Helps cache any JSON object on disk
* Very simple, without expiration
*/
@interface CacheHelper : NSObject

+(instancetype)sharedInstance;

-(void)cacheJSONObject:(id)dict key:(NSString *)key;
-(void)cacheJSONObject:(id)dict key:(NSString *)key completion:(void(^)(BOOL success))callback;
-(void)cacheFileWithURL:(NSURL *)url key:(NSString *)key;
-(void)cacheFileWithURL:(NSURL *)url key:(NSString *)key completion:(void(^)(BOOL success, id result))callback;
-(void)cachedFileWithKey:(NSString *)key callback:(void(^)(BOOL success, id result))callback;
-(void)cachedJSONObjectWithKey:(NSString *)key callback:(void(^)(BOOL success, id result))callback;

/**
* Check if file by key exists
*/
-(BOOL)peekCachedFileWithKey:(NSString *)key;

-(NSString *)pathToKey:(NSString *)key;

@end
