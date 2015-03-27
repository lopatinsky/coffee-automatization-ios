//
//  IHMenuCategory.h
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 18.08.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBMenuCategory : NSObject

@property(strong, nonatomic, readonly) NSString *categoryId;
@property(strong, nonatomic, readonly) NSString *name;
@property(strong, nonatomic, readonly) NSString *imageUrl;
@property(strong, nonatomic, readonly) NSMutableArray *positions;

@property(strong, nonatomic, readonly) NSArray *venuesRestrictions;

@property(strong, nonatomic, readonly) NSDictionary *categoryDictionary;

+ (instancetype)categoryFromResponseDictionary:(NSDictionary *)categoryDictionary;
- (void)synchronizeWithResponseDictionary:(NSDictionary *)categoryDictionary;
@end
