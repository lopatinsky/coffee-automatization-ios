//
//  DeliveryManager.h
//  DoubleB
//
//  Created by Balaban Alexander on 09/06/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * __nonnull DeliveryManagerDidRecieveSuggestionsNotification;

@interface DeliveryManager : NSObject

@property (nonatomic, strong) NSString * __nonnull city;
@property (nonatomic, strong) NSString * __nonnull street;
@property (nonatomic, strong) NSString * __nonnull house;
@property (nonatomic, strong) NSString * __nonnull corpus;
@property (nonatomic, strong) NSString * __nonnull apartment;

+ (nonnull instancetype)sharedManager;

- (void)requestSuggestions;
- (nonnull NSArray *)addressSuggestions;
- (nonnull NSArray *)listOfCities;

@end

