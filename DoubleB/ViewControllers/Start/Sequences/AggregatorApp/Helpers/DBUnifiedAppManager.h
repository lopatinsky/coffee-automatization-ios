//
//  DBUnifiedAppManager.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBPrimaryManager.h"
#import "DBUnifiedCity.h"

#import <CoreLocation/CoreLocation.h>

@interface DBUnifiedAppManager : DBPrimaryManager

@property (nonatomic) BOOL citiesLoaded;
- (NSArray *)cities;
- (NSArray *)venues;
- (NSArray *)menu;
- (NSArray *)cities:(NSString *)predicate;
- (NSArray *)allPositions;
- (NSDictionary *)positionsForItem:(NSNumber *)stringId;

+ (DBUnifiedCity *)selectedCity;
+ (void)selectCity:(DBUnifiedCity *)city;

- (void)fetchCities:(void(^)(BOOL success))callback;
- (void)fetchMenu:(void(^)(BOOL success))callback;
- (void)fetchVenues:(void (^)(BOOL success))callback;
- (void)fetchPositionsWithId:(NSString *)itemId withCallback:(void (^)(BOOL))callback;

@end