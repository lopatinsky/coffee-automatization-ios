//
//  DBCitiesManager.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 18/01/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBPrimaryManager.h"

@interface DBUnifiedCity : NSObject

@property (strong, nonatomic) NSString *cityId;
@property (strong, nonatomic) NSString *cityName;

- (instancetype)initWithResponseDict:(NSDictionary *)response;

@end

@interface DBCitiesManager : DBPrimaryManager
@property (nonatomic) BOOL citiesLoaded;

- (NSArray *)cities;
- (NSArray *)cities:(NSString *)predicate;

+ (DBUnifiedCity *)selectedCity;
+ (void)selectCity:(DBUnifiedCity *)city;

- (void)fetchCities:(void(^)(BOOL success))callback;

@end
