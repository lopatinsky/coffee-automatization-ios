//
//  DBTextResourcesHelper.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 14.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBTextResourcesHelper.h"
#import "Venue.h"
#import "DBCompanyInfo.h"

@implementation DBTextResourcesHelper

+ (NSString *)db_venuesTitleString{
    NSString *title = NSLocalizedString(@"Точки", nil);
    if([DBCompanyInfo sharedInstance].type == DBCompanyTypeCafe){
        NSUInteger venuesCount = [[Venue storedVenues] count];
        if(venuesCount == 1){
            title = NSLocalizedString(@"Кофейня", nil);
        } else {
            title = NSLocalizedString(@"Кофейни", nil);
        }
    }
    
    if([[DBCompanyInfo sharedInstance].bundleName.lowercaseString isEqualToString:@"sushimarket"]){
        title = NSLocalizedString(@"Магазины", nil);
    }
    
    return title;
}

@end
