//
//  Venue.m
//  DoubleB
//
//  Created by Sergey Pronin on 7/31/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "Venue.h"
#import "CoreDataHelper.h"
#import "DBAPIClient.h"

#import "NSDate+Difference.h"

static NSMutableArray *storedVenues;
static NSMutableArray *unifiedStoredVenues;

@implementation Venue
@dynamic venueId, address, title, latitude, longitude, workingTime, phone;
@synthesize distance;

- (void)applyDict:(NSDictionary *)dict {
    self.venueId = dict[@"id"];
    self.title = dict[@"title"];
    self.address = dict[@"address"];
    self.location = CLLocationCoordinate2DMake([dict[@"lat"] doubleValue], [dict[@"lon"] doubleValue]);
    self.phone = [dict getValueForKey:@"called_phone"] ?: @"";
    self.workingTime = [self parseWorkTimeFromSchedule:dict[@"schedule"]];
    
//    self.workingTime = [self parseWorkTimeFromSchedule:dict[@"schedule"]];
    self.workingTime = [dict getValueForKey:@"schedule_str"] ?: [self parseWorkTimeFromSchedule:dict[@"schedule"]];

    NSMutableDictionary *_dict = [dict mutableCopy];
    NSArray *keysForNullValues = [_dict allKeysForObject:[NSNull null]];
    [_dict removeObjectsForKeys:keysForNullValues];
    
    NSDictionary *companyDictionary = [_dict objectForKey:@"company"];
    if (companyDictionary) {
        NSMutableDictionary *prune = [companyDictionary mutableCopy];
        NSArray *keysForNullValues = [prune allKeysForObject:[NSNull null]];
        [prune removeObjectsForKeys:keysForNullValues];
        _dict[@"company"] = prune;
    }
    
    self.venueDictionary = _dict;
}

- (void)setLocation:(CLLocationCoordinate2D)location {
    self.latitude = location.latitude;
    self.longitude = location.longitude;
}

- (CLLocationCoordinate2D)location {
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

+ (instancetype)storedVenueForId:(NSString *)venueId {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Venue"];
    request.predicate = [NSPredicate predicateWithFormat:@"venueId == %@", venueId];
    request.fetchLimit = 1;
    
    NSArray *venues = [[CoreDataHelper sharedHelper].context executeFetchRequest:request error:nil];
    return [venues count] > 0 ? venues[0] : nil;
}

+ (NSArray *)storedVenues {
    if(!storedVenues){
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Venue"];
        storedVenues = [NSMutableArray arrayWithArray:[[CoreDataHelper sharedHelper].context executeFetchRequest:request error:nil]];
    }

    return storedVenues;
}

+ (Venue *)venueById:(NSString *)venueId{
    return [self storedVenueForId:venueId];
}

- (void)setVenueDictionary:(NSDictionary *)venueDictionary {
    [[NSUserDefaults standardUserDefaults] setObject:venueDictionary forKey:[NSString stringWithFormat:@"venue_dict_%@", self.venueId]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDictionary *)venueDictionary {
    return [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"venue_dict_%@", self.venueId]];
}

#pragma mark - Storage
+ (void)dropAllVenues {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Venue"];
    
    NSArray *venues = [[CoreDataHelper sharedHelper].context executeFetchRequest:request error:nil];
    for (Venue *venue in venues) {
        [[CoreDataHelper sharedHelper].context deleteObject:venue];
    }
}

+ (void)syncVenues:(NSArray *)responseVenues {
    for (Venue *venue in storedVenues) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", venue.venueId];
        NSDictionary *responseVenue = [[responseVenues filteredArrayUsingPredicate:predicate] firstObject];
        if(!responseVenue) {
            [[CoreDataHelper sharedHelper].context deleteObject:venue];
        }
    }
    
    for (NSDictionary *dict in responseVenues) {
        Venue *venue = [self storedVenueForId:dict[@"id"]];
        if (venue) {
            [venue applyDict:dict];
        } else {
            venue = [NSEntityDescription insertNewObjectForEntityForName:@"Venue" inManagedObjectContext:[CoreDataHelper sharedHelper].context];
            [venue applyDict:dict];
        }
    }
    
    [[CoreDataHelper sharedHelper] save];
    [Venue updateUserActivities];
    storedVenues = nil;
}

+ (NSArray *)venuesFromDict:(NSArray *)responseVenues {
    NSMutableArray *venues = [NSMutableArray new];
    
    for (NSDictionary *dict in responseVenues) {
        Venue *venue = [self storedVenueForId:dict[@"id"]];
        if (venue) {
            [venue applyDict:dict];
        } else {
            venue = [NSEntityDescription insertNewObjectForEntityForName:@"Venue" inManagedObjectContext:[CoreDataHelper sharedHelper].context];
            [venue applyDict:dict];
        }
        [venues addObject:venue];
    }
    
    return venues;
}

#pragma mark - Auxiliary
- (NSString *)parseWorkTimeFromSchedule:(NSArray *)schedule{
    NSMutableString *result = [NSMutableString stringWithString:@""];
    for (NSDictionary *scheduleItem in  schedule){
        NSArray *days = scheduleItem[@"days"];
        NSString *hours = scheduleItem[@"hours"];
        NSString *minutes = scheduleItem[@"minutes"];
        
        [result appendString:[self dayByNumber:[[days firstObject] intValue]]];
        if([days count] > 1){
            [result appendString:@"-"];
            [result appendString:[self dayByNumber:[[days lastObject] intValue]]];
        }
        [result appendString:@" "];
        
        NSArray *hoursArray = [hours componentsSeparatedByString:@"-"];
        NSArray *minutesArray = [minutes componentsSeparatedByString:@"-"];
        [result appendString:hoursArray[0]];
        [result appendString:@":"];
        [result appendString:minutesArray[0]];
        [result appendString:@"-"];
        [result appendString:hoursArray[1]];
        [result appendString:@":"];
        [result appendString:minutesArray[1]];
        
        if(scheduleItem != [schedule lastObject]){
            [result appendString:@", "];
        }
    }
    
    return [result capitalizedString];
}

- (NSString *)dayByNumber:(int)number{
    NSString *result = @"";
    
    switch (number) {
        case 1:
            result = @"пн";
            break;
        case 2:
            result = @"вт";
            break;
        case 3:
            result = @"ср";
            break;
        case 4:
            result = @"чт";
            break;
        case 5:
            result = @"пт";
            break;
        case 6:
            result = @"сб";
            break;
        case 7:
            result = @"вс";
            break;
            
        default:
            break;
    }
    
    return result;
}

+ (void)updateUserActivities {
    NSArray *venues = [Venue storedVenues];
    for (Venue *venue in venues) {
        if ([venue activityIsAvailable]) {
            [[AppIndexingManager sharedManager] postActivity:venue withParams:@{@"type": @"venue",
                                                                                @"expirationDate": [[NSDate date] dateByAddingTimeInterval:60 * 60 * 24 * 7],
                                                                                @"eligibleForSearch": @(YES),
                                                                                @"eligibleForPublicIndexing": @(YES)}];
        }
    }
}

#pragma mark - UserActivityIndexing protocol
- (CSSearchableItemAttributeSet *)activityAttributes {
    CSSearchableItemAttributeSet *set = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(NSString *)kUTTypeImage];
    set.contentDescription = [NSString stringWithFormat:@"%@\n%@\n%.2f m", self.address, self.workingTime, self.distance];
    return set;
}

- (NSString *)activityTitle {
    return self.title;
}

- (NSDictionary *)activityUserInfo {
    return @{@"venue_id": self.venueId ?: @""};
}

- (void)activityDidAppear {
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[NSString stringWithFormat:@"last_indexing_venue_%@", [self venueId]]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)activityIsAvailable {
    NSDate *lastPublicationDate = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"last_indexing_venue_%@", [self venueId]]] ?: [NSDate dateWithTimeIntervalSince1970:0];
    return [lastPublicationDate numberOfDaysUntil:[NSDate date]] > 7;
}

@end

#pragma mark - API
@implementation Venue (API)

+ (void)fetchAllVenuesWithCompletionHandler:(void(^)(NSArray *venues))completionHandler {
    [self fetchVenuesForLocation:nil withCompletionHandler:completionHandler];
}

+ (void)fetchVenuesForLocation:(CLLocation *)location withCompletionHandler:(void(^)(NSArray *venues))completionHandler {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (location) {
        params[@"ll"] = [NSString stringWithFormat:@"%f,%f", location.coordinate.latitude, location.coordinate.longitude];
    }
    
    NSDate *startTime = [NSDate date];
    [[DBAPIClient sharedClient] GET:@"venues"
                         parameters:params
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                //NSLog(@"%@", responseObject);
                                
                                [self syncVenues:responseObject[@"venues"]];
                                
                                NSDate *endTime = [NSDate date];
                                int interval = [endTime timeIntervalSince1970] - [startTime timeIntervalSince1970];
                                
                                [GANHelper analyzeEvent:@"venues_load_success"
                                                 number:@(interval)
                                               category:APPLICATION_START];
                                
                                if(completionHandler)
                                    completionHandler([self storedVenues]);
                            }
                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"%@", error);
                                
                                [GANHelper analyzeEvent:@"venues_load_failed"
                                                  label:error.description
                                               category:APPLICATION_START];
                                
                                if(completionHandler)
                                    completionHandler(nil);
                            }];
}

@end

