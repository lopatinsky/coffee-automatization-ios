//
//  DBVenue.h
//  DoubleB
//
//  Created by Balaban Alexander on 25/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DBCompaniesManager.h"
#import "Venue.h"

@interface DBUnifiedVenue : NSObject

@property (nonatomic, strong) NSString *venueAddress;
@property (nonatomic, strong) NSString *venueCalledPhone;
@property (nonatomic, strong) NSString *venueCoordinates;
@property (nonatomic, strong) NSNumber *venueId;
@property (nonatomic, strong) NSString *venuePicture;
@property (nonatomic, strong) NSString *venueScheduleString;
@property (nonatomic, strong) NSString *venueTitle;
@property (nonatomic) BOOL venueIsOpen;
@property (nonatomic, strong) NSDictionary *venueDictionary;
@property (nonatomic, strong) Venue *venueObject;
@property (nonatomic, strong) DBCompany *company;

+ (NSArray *)venuesFromDictionary:(NSArray *)venues;
- (instancetype)initWithDictionary:(NSDictionary *)venue;

@end
