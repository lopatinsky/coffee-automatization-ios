//
//  IHMenuCategory.h
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 18.08.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Venue;
@class DBMenuPosition;

@interface DBMenuCategory : NSObject

@property(strong, nonatomic, readonly) NSString *categoryId;
@property(strong, nonatomic, readonly) NSString *name;
@property(strong, nonatomic, readonly) NSString *imageUrl;
@property(strong, nonatomic) NSMutableArray *positions;

@property(strong, nonatomic, readonly) NSArray *venuesRestrictions;

@property(strong, nonatomic, readonly) NSDictionary *categoryDictionary;

// Not stored data
@property(nonatomic, readonly) BOOL hasImage;
@property(nonatomic, readonly) BOOL categoryWithImages;

+ (instancetype)categoryFromResponseDictionary:(NSDictionary *)categoryDictionary;
- (void)synchronizeWithResponseDictionary:(NSDictionary *)categoryDictionary;

- (BOOL)availableInVenue:(Venue *)venue;
- (NSMutableArray *)filterPositionsForVenue:(Venue *)venue;
- (DBMenuPosition *)findPositionWithId:(NSString *)positionId;

@end
