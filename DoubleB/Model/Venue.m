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

static NSMutableArray *storedVenues;

@implementation Venue
@dynamic venueId, address, title, latitude, longitude, workingTime, hasTablesInside;
@synthesize distance;

- (void)applyDict:(NSDictionary *)dict {
    self.venueId = dict[@"id"];
    self.title = dict[@"title"];
    self.address = dict[@"address"];
    self.distance = [dict[@"distance"] doubleValue];
    self.location = CLLocationCoordinate2DMake([dict[@"lat"] doubleValue], [dict[@"lon"] doubleValue]);
    self.hasTablesInside = @(![dict[@"takeout_only"] boolValue]);
    
    self.workingTime = [self parseWorkTimeFromSchedule:dict[@"schedule"]];
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
        
        [storedVenues sortUsingComparator:^NSComparisonResult(Venue *obj1, Venue *obj2) {
            return [@(obj1.distance) compare:@(obj2.distance)];
        }];
    }

    return storedVenues;
}

+ (Venue *)venueById:(NSString *)venueId{
    return [self storedVenueForId:venueId];
}

+ (void)dropAllVenues {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Venue"];
    
    NSArray *venues = [[CoreDataHelper sharedHelper].context executeFetchRequest:request error:nil];
    for (Venue *venue in venues) {
        [[CoreDataHelper sharedHelper].context deleteObject:venue];
    }
}

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

+ (void)syncVenues:(NSArray *)responseVenues {
    for (Venue *venue in storedVenues) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", venue.venueId];
        NSDictionary *responseVenue = [[responseVenues filteredArrayUsingPredicate:predicate] firstObject];
        if(!responseVenue) {
            [[CoreDataHelper sharedHelper].context deleteObject:venue];
        }
    }
    
    // TODO: add called phone to database Venue model?
    NSMutableDictionary *calledPhones = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"venue_called_phones"] ?: @{}];
    for (NSDictionary *dict in responseVenues) {
        Venue *venue = [self storedVenueForId:dict[@"id"]];
        if ([dict objectForKey:@"called_phone"] && ![[dict objectForKey:@"called_phone"] isEqualToString:@""]) {
            calledPhones[dict[@"id"]] = [dict objectForKey:@"called_phone"];
        }
        if (venue) {
            [venue applyDict:dict];
        } else {
            venue = [NSEntityDescription insertNewObjectForEntityForName:@"Venue" inManagedObjectContext:[CoreDataHelper sharedHelper].context];
            [venue applyDict:dict];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:calledPhones forKey:@"venue_called_phones"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[CoreDataHelper sharedHelper] save];
    storedVenues = nil;
}

+ (NSString *)calledPhone:(NSString *)venueId {
    NSDictionary *calledPhones = [[NSUserDefaults standardUserDefaults] objectForKey:@"venue_called_phones"];
    return [calledPhones objectForKey:venueId];
}

- (NSString *)parseWorkTimeFromSchedule:(NSArray *)schedule{
    NSMutableString *result = [NSMutableString stringWithString:@""];
    for(NSDictionary *scheduleItem in  schedule){
        NSArray *days = scheduleItem[@"days"];
        NSString *hours = scheduleItem[@"hours"];
        
        [result appendString:[self dayByNumber:[[days firstObject] intValue]]];
        if([days count] > 1){
            [result appendString:@"-"];
            [result appendString:[self dayByNumber:[[days lastObject] intValue]]];
        }
        [result appendString:@" "];
        [result appendString:hours];
        
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

@end
