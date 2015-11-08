//
//  DBUnifiedAppManager.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBPrimaryManager.h"
#import <CoreLocation/CoreLocation.h>

@interface DBCity : NSObject<NSCoding>
@property (strong, nonatomic) NSString *cityId;
@property (strong, nonatomic) NSString *cityName;
@end

@interface DBUnifiedAppManager : DBPrimaryManager

- (NSArray *)cities;
- (NSArray *)cities:(NSString *)predicate;

+ (DBCity *)selectedCity;
+ (void)selectCity:(DBCity *)city;

- (void)fetchCities:(void(^)(BOOL success))callback;

@end
