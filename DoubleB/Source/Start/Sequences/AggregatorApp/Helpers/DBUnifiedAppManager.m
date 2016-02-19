//
//  DBUnifiedAppManager.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBUnifiedAppManager.h"
#import "DBUnifiedVenue.h"
#import "DBUnifiedPosition.h"

#import "DBAPIClient.h"
#import "NetworkManager.h"
#import "DBCitiesManager.h"
#import "Venue.h"

#import "DBMenuPosition.h"

@interface DBUnifiedAppManager()

@property (nonatomic, strong) NSMutableDictionary *positions;

@end

@implementation DBUnifiedAppManager

- (NSArray *)allPositions {
    NSData *menuData = [DBUnifiedAppManager valueForKey:@"menu"];
    if (menuData) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:menuData];
    } else {
        return @[];
    }
}

- (NSArray *)positionsForItem:(NSNumber *)stringId {
    NSArray *allPositions = [self.positions getValueForKey:[NSString stringWithFormat:@"positions_%@", stringId]] ?: @[];
    return allPositions;
}

- (NSArray *)menu {
    return [DBUnifiedAppManager valueForKey:@"menu"] ?: @[];
}

- (NSArray *)venues {
    NSArray *venuesData = [DBUnifiedAppManager valueForKey:@"venues"] ?: @[];
    return [DBUnifiedVenue venuesFromDictionary:venuesData];
}

- (void)fetchMenu:(void (^)(BOOL))callback {
    [[DBAPIClient sharedClient] GET:@"proxy/unified_app/menu"
                         parameters:@{}
                            success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                                NSLog(@"%@", responseObject);
                                
                                NSMutableArray *prunedArray = [NSMutableArray new];
                                for (NSDictionary *position in responseObject[@"items"]) {
                                    NSMutableDictionary *_dict = [position mutableCopy];
                                    NSArray *keysForNullValues = [_dict allKeysForObject:[NSNull null]];
                                    [_dict removeObjectsForKeys:keysForNullValues];
                                    [prunedArray addObject:_dict];
                                }
                                
                                [DBUnifiedAppManager setValue:prunedArray forKey:@"menu"];
                                [DBUnifiedAppManager setValue:@(YES) forKey:@"menuLoaded"];
                                
                                if (callback) {
                                    callback(YES);
                                }
                            }
                            failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                                NSLog(@"%@", error);
                                
                                if (callback) {
                                    callback(NO);
                                }
                            }];
}

- (void)fetchVenues:(void (^)(BOOL))callback {
    [[DBAPIClient sharedClient] GET:@"proxy/unified_app/venues"
                         parameters:nil
                            success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                                NSArray *venues = [DBUnifiedVenue venuesFromDictionary:responseObject[@"venues"]];
                                NSMutableArray *venuesDictionaries = [NSMutableArray new];
                                for (DBUnifiedVenue *venue in venues) {
                                    [venuesDictionaries addObject:venue.venueDictionary];
                                }
                                [DBUnifiedAppManager setValue:venuesDictionaries forKey:@"venues"];
                                [DBUnifiedAppManager setValue:@(YES) forKey:@"venuesLoaded"];
                                
                                if (callback) {
                                    callback(YES);
                                }
                            }
                            failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                                NSLog(@"%@", error);
                                
                                if (callback) {
                                    callback(NO);
                                }
                            }];
}

- (void)fetchPositionsWithId:(NSNumber *)itemId withCallback:(void (^)(BOOL))callback {
    [[DBAPIClient sharedClient] GET:[NSString stringWithFormat:@"proxy/unified_app/product?product_id=%@", itemId]
                         parameters:nil
                            success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                                NSLog(@"%@", responseObject);
                                
                                if (!self.positions) {
                                    self.positions = [NSMutableDictionary new];
                                }
                                
                                NSMutableArray *allPositions = [NSMutableArray new];
                                for (NSDictionary *item in responseObject[@"venues"]) {
                                    DBUnifiedPosition *position = [[DBUnifiedPosition alloc] initWithResponseDict:item];
                                    [allPositions addObject:position];
                                    
                                }
                                self.positions[[NSString stringWithFormat:@"positions_%@", itemId]] = allPositions;
                                
                                if (callback) {
                                    callback(YES);
                                }
                            }
                            failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                                NSLog(@"%@", error);
                                
                                if (callback) {
                                    callback(NO);
                                }
                            }];
}

+ (NSString *)db_managerStorageKey {
    return @"kDBDBUnifiedAppManagerDefaultsInfo";
}

@end
