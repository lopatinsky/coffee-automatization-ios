//
// Created by Sergey Pronin on 6/21/14.
// Copyright (c) 2014 Empatika. All rights reserved.
//

#import "MenuHelper.h"
#import "DBAPIClient.h"
#import "IHSecureStore.h"
#import "CacheHelper.h"
#import "Position.h"
#import "DBMenuCategory.h"
#import "MenuPositionExtension.h"

@interface MenuHelper ()
@property (nonatomic) BOOL isUpdated;
@end

@implementation MenuHelper

+ (instancetype)sharedHelper {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [self new];
    });
    
    return _sharedInstance;
}

- (BOOL)getMenuForVenue:(NSString *)venueId completionHandler:(void(^)(id response))completionHandler {
    
    void (^menuHandler)(BOOL, id) = ^void(BOOL success, id result){
        if(success){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"venue_id == %@", venueId];
            NSArray *menus = result[@"menu"];
            NSDictionary *menuForVenue = [[menus filteredArrayUsingPredicate:predicate] firstObject];
            NSMutableArray *resultArray = [[NSMutableArray alloc] init];
            for(NSDictionary *category in menuForVenue[@"menu"]){
                [resultArray addObject:[DBMenuCategory category:category[@"id"] name:category[@"title"] items:[self someMagicWithMenu:category[@"items"]]]];
            }
            
            if(completionHandler)
                completionHandler(resultArray);
            self.fetchedMenu = resultArray;
        } else {
            if(completionHandler)
                completionHandler(nil);
        }
    };
    
    BOOL fromCache = NO;
    if ([[CacheHelper sharedInstance] peekCachedFileWithKey:@"menu"]) {
        [[CacheHelper sharedInstance] cachedJSONObjectWithKey:@"menu" callback:^(BOOL success, id result) {
            menuHandler(success, result);
        }];
        fromCache = YES;
    }
    if(!self.isUpdated){
        [self fetchMenuWithCompletionHandler:menuHandler];
    }
    return fromCache;
}

- (void)fetchMenuWithCompletionHandler:(void(^)(BOOL success, id result))completionHandler {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *clientId = [[IHSecureStore sharedInstance] clientId];
    if (clientId) {
        params[@"client_id"] = clientId;
        params[@"language"] = [[NSLocale preferredLanguages] objectAtIndex:0];;
    }
    
    [[DBAPIClient sharedClient] GET:@"menu.php"
                         parameters:params
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                [[CacheHelper sharedInstance] cacheJSONObject:responseObject key:@"menu"];
                                
                                self.isUpdated = YES;
                                
                                [[IHSecureStore sharedInstance] setClientId:[NSString stringWithFormat:@"%lld",
                                                                             (long long)[responseObject[@"client_id"] longLongValue]]];
                                if(completionHandler)
                                    completionHandler(YES, responseObject);
                            }
                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"%@", error);
                                if(completionHandler)
                                    completionHandler(NO, nil);
                            }];
}

- (void)fetchMenuAndGetPreviewFlag:(void(^)(BOOL shouldBindCard, NSError *error))completionHandler{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *clientId = [[IHSecureStore sharedInstance] clientId];
    if (clientId) {
        params[@"client_id"] = clientId;
        params[@"language"] = [[NSLocale preferredLanguages] objectAtIndex:0];;
    }
    [[DBAPIClient sharedClient] GET:@"menu.php"
                         parameters:params
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                //NSLog(@"%@", responseObject);
                                [[CacheHelper sharedInstance] cacheJSONObject:responseObject key:@"menu"];
                                
                                BOOL shouldBindCardForAuthorization = [responseObject[@"demo"] boolValue];
                                [[NSUserDefaults standardUserDefaults] setObject:@(shouldBindCardForAuthorization)
                                                                          forKey:kDBBindingNecessaryForAuthorization];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                                
                                [[IHSecureStore sharedInstance] setClientId:[NSString stringWithFormat:@"%lld",
                                                                             (long long)[responseObject[@"client_id"] longLongValue]]];
                                
                                completionHandler(shouldBindCardForAuthorization, nil);
                            }
                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"%@", error);
                                
                                completionHandler(YES, error);
                            }];
}

// These two methods should be actual only while server not implement new menu model
- (NSMutableArray *)someMagicWithMenu:(NSArray *)responsePositions{
    NSMutableArray *positions = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in responsePositions) {
        NSDictionary *resultDict = [self fetchNameAndExtFromPositionName:dict[@"title"] price:dict[@"price"]];
        if(resultDict[@"ext"]){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@", resultDict[@"title"]];
            Position *samePosition = [[positions filteredArrayUsingPredicate:predicate]firstObject];
            if(samePosition){
                [samePosition.exts addObject:[MenuPositionExtension extensionWithName:resultDict[@"ext"] id:dict[@"id"] price:dict[@"price"]]];
            } else {
                NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                newDict[@"title"] = resultDict[@"title"];
                Position *newPosition = [Position positionWithDictionary:newDict];
                [newPosition.exts addObject:[MenuPositionExtension extensionWithName:resultDict[@"ext"] id:dict[@"id"] price:dict[@"price"]]];
                [positions addObject:newPosition];
            }
        } else {
            [positions addObject:[Position positionWithDictionary:dict]];
        }
    }
    
    for(Position *position in positions){
        if([position.exts count] == 1){
            position.title = [NSString stringWithFormat:@"%@ (%@)", position.title, ((MenuPositionExtension *)position.exts[0]).extName];
            [position.exts removeAllObjects];
        }
    }
    
    return positions;
}

- (NSDictionary *)fetchNameAndExtFromPositionName:(NSString *)name price:(NSNumber *)price{
    NSError *error = nil;
    NSString *pattern = @"(.+)\\s*\\((.*)\\)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *matches = [regex matchesInString:name options:0 range:NSMakeRange(0, name.length)];
    
    NSString *title;
    NSString *ext;
    
    if([matches count] > 0){
        NSTextCheckingResult *match = matches[0];
        title = [name substringWithRange:[match rangeAtIndex:1]];
        ext = [name substringWithRange:[match rangeAtIndex:2]];
    }
    else {
        title = name;
        ext = nil;
    }
    
    
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
    if(title){
        resultDict[@"title"] = title;
    }
    if(ext){
        resultDict[@"ext"] = ext;
    }
    resultDict[@"price"] = price;
    
    
    return resultDict;
}

/*- (Position *)findPositionWithId:(NSString *)itemId{
 NSString *otherItemId = [NSString stringWithFormat:@"%@", itemId];
 NSPredicate *predicate = [NSPredicate predicateWithFormat:@"positionId == %@", otherItemId];
 
 Position *result = [[self.cachedMenu filteredArrayUsingPredicate:predicate] firstObject];
 
 return result;
 }*/

//- (Position *)findPositionWithName:(NSString *)itemName{
//    NSString *otherItemName = [NSString stringWithFormat:@"%@", itemName];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@", otherItemName];
//
//    Position *result = [[self.cachedMenu filteredArrayUsingPredicate:predicate] firstObject];
//
//    return result;
//}

@end