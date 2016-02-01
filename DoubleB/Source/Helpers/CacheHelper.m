//
//  CacheHelper.m
//  PromoteEducate-ios
//
//  Created by Sergey Pronin on 05/18/13.
//  Copyright (c) 2013 Sergey Pronin. All rights reserved.
//

#import "CacheHelper.h"

@implementation CacheHelper {
    NSFileManager *fileManager;
    NSMutableArray *cachingArray;
}

+(instancetype)sharedInstance {
    static dispatch_once_t once = 0;
    static CacheHelper *instance = nil;
    dispatch_once(&once, ^{ instance = [[self alloc] init]; });
    return instance;
}

-(id)init {
    self = [super init];
    if (self) {
        fileManager = [NSFileManager defaultManager];
        cachingArray = [NSMutableArray array];
    }
    return self;
}

-(void)cachedFileWithKey:(NSString *)key callback:(void(^)(BOOL success, id result))callback {
    NSString *path = [self pathToKey:key];
    if (![fileManager fileExistsAtPath:path]) {
        callback(NO, nil);
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSError *error = nil;
        NSData *fileData = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:&error];
        if (error || !fileData) {
            NSLog(@"cached file opening fail: %@", key);
            dispatch_async(dispatch_get_main_queue(), ^{
                BLOCK_SAFE_RUN(callback, NO, nil);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                BLOCK_SAFE_RUN(callback, YES, fileData);
            });
        }
    });
}

-(void)cachedJSONObjectWithKey:(NSString *)key callback:(void(^)(BOOL success, id result))callback {
    NSString *path = [self pathToKey:key];
    if (![fileManager fileExistsAtPath:path]) {
        callback(NO, nil);
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (!dict) {
            NSLog(@"cached file opening fail: %@", key);
            dispatch_async(dispatch_get_main_queue(), ^{
                BLOCK_SAFE_RUN(callback, NO, nil);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                BLOCK_SAFE_RUN(callback, YES, dict);
            });
        }
    });
}

-(BOOL)peekCachedFileWithKey:(NSString *)key {
    return [fileManager fileExistsAtPath:[self pathToKey:key]];
}

-(void)cacheJSONObject:(id)dict key:(NSString *)key {
    [self cacheJSONObject:dict key:key completion:NULL];
}

-(void)cacheJSONObject:(id)dict key:(NSString *)key completion:(void(^)(BOOL success))callback {
    @synchronized (cachingArray) {
        if ([cachingArray containsObject:key]) return;
        [cachingArray addObject:key];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *path = [self pathToKey:key];
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
        if (![data writeToFile:path atomically:YES]) {
            @synchronized (cachingArray) {
                [cachingArray removeObject:key];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                BLOCK_SAFE_RUN(callback, NO);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                BLOCK_SAFE_RUN(callback, YES);
            });
        }
    });
}

-(void)cacheFileWithURL:(NSURL *)url key:(NSString *)key completion:(void(^)(BOOL success, id result))callback {
    @synchronized (cachingArray) {
        if ([cachingArray containsObject:key]) return;
        [cachingArray addObject:key];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *fileData = [NSData dataWithContentsOfURL:url];
        if (!fileData) return;

        NSString *path = [self pathToKey:key];
        if (![fileData writeToFile:path atomically:YES]) {
            @synchronized (cachingArray) {
                [cachingArray removeObject:key];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                BLOCK_SAFE_RUN(callback, NO, nil);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                BLOCK_SAFE_RUN(callback, YES, fileData);
            });
        }
    });
}

-(void)cacheFileWithURL:(NSURL *)url key:(NSString *)key {
    [self cacheFileWithURL:url key:key completion:NULL];
}

-(NSString *)pathToKey:(NSString *)key {
    return [[NSString documentsDirectory] stringByAppendingPathComponent: [NSString stringWithFormat:@"file_%@", key]];
}

@end
