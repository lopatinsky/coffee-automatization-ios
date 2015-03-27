//
//  IHMenuProduct.h
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 18.08.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBMenuPosition : NSObject

@property(strong, nonatomic, readonly) NSString *positionId;
@property(strong, nonatomic, readonly) NSString *name;
@property(nonatomic, readonly) double price;
@property(strong, nonatomic, readonly) NSString *imageUrl;
@property(strong, nonatomic, readonly) NSString *positionDescription;
@property(nonatomic, readonly) double energyAmount;
@property(nonatomic, readonly) double weight;
@property(nonatomic, readonly) double volume;

@property(strong, nonatomic, readonly) NSMutableArray *groupModifiers;
@property(strong, nonatomic, readonly) NSMutableArray *singleModifiers;

@property(strong, nonatomic, readonly) NSArray *venuesRestrictions;

@property(strong, nonatomic, readonly) NSDictionary *productDictionary;

+ (instancetype)positionFromResponseDictionary:(NSDictionary *)positionDictionary;
- (void)synchronizeWithResponseDictionary:(NSDictionary *)positionDictionary;

@end
