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

+ (NSString *)db_venuesTitleString {
    NSString *title = NSLocalizedString(@"Заведения", nil);
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
    
    if([[DBCompanyInfo sharedInstance].bundleName.lowercaseString isEqualToString:@"pastadeli"]){
        title = NSLocalizedString(@"Пастерии", nil);
    }
    
    return title;
}

+ (NSString *)db_preparationOrderCellString {
    if ([[DBCompanyInfo sharedInstance].bundleName.lowercaseString isEqualToString:@"coffeeacademy"] || [[DBCompanyInfo sharedInstance].bundleName.lowercaseString isEqualToString:@"testapp"]) {
        return NSLocalizedString(@"Мы постараемся приготовить к %@", nil);
    } else {
        return NSLocalizedString(@"Готов к %@", nil);
    }
}

+ (NSString *)db_readyOrderCellString {
    return NSLocalizedString(@"Готов к %@", nil);
}

+ (NSString *)db_shareBgImageName {
    NSString *imageName = @"share";
    
    if ([[DBCompanyInfo sharedInstance].bundleName.lowercaseString isEqualToString:@"redcup"]) {
        imageName = @"share_redcup";
    }
    
    if ([[DBCompanyInfo sharedInstance].bundleName.lowercaseString isEqualToString:@"coffeeacademy"]) {
        imageName = @"share_coffeeacademy";
    }
    
    if ([[DBCompanyInfo sharedInstance].bundleName.lowercaseString isEqualToString:@"voda"]) {
        imageName = @"share_voda";
    }
    
    return imageName;
}

+ (UIColor *)db_shareScreenTextColor {
    UIColor *color = [UIColor whiteColor];
    
    if ([[DBCompanyInfo sharedInstance].bundleName.lowercaseString isEqualToString:@"voda"]) {
        color = [UIColor blackColor];
    }
    
    return color;
}

@end
