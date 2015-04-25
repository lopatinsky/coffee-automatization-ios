//
//  IHMenuProduct.h
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 18.08.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Venue;

@interface DBMenuPosition : NSObject<NSCopying>

@property(strong, nonatomic, readonly) NSString *positionId;
@property(strong, nonatomic, readonly) NSString *name;
@property(nonatomic, readonly) NSInteger order;
@property(nonatomic, readonly) double price;
@property(nonatomic, readonly) double actualPrice;
@property(strong, nonatomic, readonly) NSString *imageUrl;
@property(strong, nonatomic, readonly) NSString *positionDescription;
@property(nonatomic, readonly) double energyAmount;
@property(nonatomic, readonly) double weight;
@property(nonatomic, readonly) double volume;

@property(strong, nonatomic, readonly) NSMutableArray *groupModifiers;
@property(strong, nonatomic, readonly) NSMutableArray *singleModifiers;

@property(strong, nonatomic, readonly) NSDictionary *productDictionary;

// Not stored data
@property(nonatomic, readonly) BOOL hasImage;

+ (instancetype)positionFromResponseDictionary:(NSDictionary *)positionDictionary;
- (void)synchronizeWithResponseDictionary:(NSDictionary *)positionDictionary;

- (BOOL)availableInVenue:(Venue *)venue;

- (void)selectItem:(NSString *)itemId forGroupModifier:(NSString *)modifierId;
- (void)addSingleModifier:(NSString *)modifierId count:(NSInteger)count;

// Returns equality of initial data
// For full equality use isEqual:
- (BOOL)isSamePosition:(DBMenuPosition *)object;

@end
