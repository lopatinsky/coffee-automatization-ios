//
//  DBVenue.m
//  DoubleB
//
//  Created by Balaban Alexander on 25/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBUnifiedVenue.h"
#import "NSDictionary+NSNullRepresentation.h"

@implementation DBUnifiedVenue

+ (NSArray *)venuesFromDictionary:(NSArray *)venues {
    NSMutableArray *venueObjects = [NSMutableArray new];
    for (NSDictionary *venueDictionary in venues) {
        [venueObjects addObject:[[DBUnifiedVenue alloc] initWithDictionary:venueDictionary]];
    }
    return [venueObjects copy];
}

- (instancetype)initWithDictionary:(NSDictionary *)venue andCompanyDictionary:(NSDictionary *)companyDictionary {
    if (self = [super init]) {
        DBCompany *company = [DBCompany new];
        company.companyNamespace = [companyDictionary getValueForKey:@"namespace"] ?: @"";
        company.companyName = [companyDictionary getValueForKey:@"title"] ?: @"";
        company.companyDescription = [companyDictionary getValueForKey:@"description"] ?: @"";
        company.companyImageUrl = [companyDictionary getValueForKey:@"image"] ?: [venue getValueForKey:@"pic"] ?: @"";
        
        self.venueAddress = [venue getValueForKey:@"address"] ?: @"";
        self.venueCalledPhone = [venue getValueForKey:@"called_phone"] ?: @"";
        self.company = company;
        self.venueCoordinates = [venue getValueForKey:@"coordinates"] ?: @"";
        self.venueId = [venue getValueForKey:@"id"] ?: @(0);
        self.venuePicture = [venue getValueForKey:@"pic"] ?: @"";
        self.venueScheduleString = [venue getValueForKey:@"schedule_str"] ?: @"";
        self.venueTitle = [venue getValueForKey:@"title"] ?: @"";
        self.venueIsOpen = [[venue getValueForKey:@"is_open"] boolValue];
        
        if ([venue objectForKey:@"venue_object"]) {
            self.venueObject = [[Venue venuesFromDict:@[[venue objectForKey:@"venue_object"]]] firstObject];
        } else {
            self.venueObject = [[Venue venuesFromDict:@[venue]] firstObject];
        }
        
        self.venueDictionary = @{
                                 @"address": self.venueAddress,
                                 @"called_phone": self.venueCalledPhone,
                                 @"coordinates": self.venueCoordinates,
                                 @"id": self.venueId,
                                 @"pic": self.venuePicture,
                                 @"schedule_str": self.venueScheduleString,
                                 @"title": self.venueTitle,
                                 @"is_open": @(self.venueIsOpen),
                                 @"venue_object": self.venueObject.venueDictionary,
                                 @"company_namespace": self.company.companyNamespace
                                 };
    }
    return self;
    
}

- (instancetype)initWithDictionary:(NSDictionary *)venue {
    NSDictionary *companyDictionary = @{
                                        @"namespace": [[venue getValueForKey:@"venue_object"] getValueForKey:@"company_namespace"] ?: @"",
                                        @"name": [[venue getValueForKey:@"venue_object"] getValueForKey:@"title"] ?: @"",
                                        @"description": @"",
                                        @"image": [[venue getValueForKey:@"venue_object"] getValueForKey:@"pic"] ?: @""
                                        };
    return [self initWithDictionary:venue andCompanyDictionary:companyDictionary];
}

@end
