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

+ (NSString *)venueRusTitle:(NSString *)key count:(int)count case:(int)wordCase {
    NSDictionary *dict = @{@"Заведение": @[@[@"Заведение", @"Заведения", @"Заведению", @"Заведение", @"Заведением", @"Заведении"],@[@"Заведения", @"Заведений", @"Заведениям", @"Заведения", @"Заведениями", @"Заведениях"]],
                           @"Кофейня": @[@[@"Кофейня", @"Кофейни", @"Кофейне", @"Кофейню", @"Кофейней", @"Кофейне"], @[@"Кофейни", @"Кофейен", @"Кофейням", @"Кофейни", @"Кофейнями", @"Кофейнях"]],
                           @"Магазин": @[@[@"Магазин", @"Магазина", @"Магазину", @"Магазин", @"Магазином", @"Магазине"], @[@"Магазины", @"Магазинов", @"Магазинам", @"Магазины", @"Магазинами", @"Магазинах"]],
                           @"Пастерия": @[@[@"Пастерия", @"Пастерии", @"Пастерии", @"Пастерию", @"Пастерией", @"Пастерии"], @[@"Пастерии", @"Пастерий", @"Пастериям", @"Пастерии", @"Пастериями", @"Пастериях"]]};
    NSArray *titles = [dict getValueForKey:key] ?: dict[@"Заведение"];
    count = count <=1 ? 1 : count;
    wordCase = wordCase < 1 ? 1 : wordCase;
    wordCase = wordCase > 6 ? 6 : wordCase;
    
    return titles[count - 1][wordCase - 1];
}

+ (NSString *)currentLocale {
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    return [language substringToIndex:2];
}

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
    
    if([[ApplicationConfig db_bundleName].lowercaseString isEqualToString:@"sushimarket"]){
        title = NSLocalizedString(@"Магазины", nil);
    }
    
    if([[ApplicationConfig db_bundleName].lowercaseString isEqualToString:@"pastadeli"]){
        title = NSLocalizedString(@"Пастерии", nil);
    }
    
    return title;
}

+ (NSString *)db_venueTitleString:(int)wordCase {
    NSString *key = @"Заведение";
    if([DBCompanyInfo sharedInstance].type == DBCompanyTypeCafe){
        key = @"Кофейня";
    }
    
    if([[ApplicationConfig db_bundleName].lowercaseString isEqualToString:@"sushimarket"]){
        key = @"Магазин";
    }
    
    if([[ApplicationConfig db_bundleName].lowercaseString isEqualToString:@"pastadeli"]){
        key = @"Пастерия";
    }
    
    if ([[self currentLocale] isEqualToString:@"en"]) {
        return NSLocalizedString(key, nil);
    } else {
        return [self venueRusTitle:key count:1 case:wordCase];
    }
}

+ (NSString *)db_venueBalanceString {
    NSString *title = NSLocalizedString(@"Наличие в магазинах", nil);
    
    return title;
}

+ (NSString *)db_preparationOrderCellString {
    if ([[ApplicationConfig db_bundleName].lowercaseString isEqualToString:@"coffeeacademy"] || [[ApplicationConfig db_bundleName].lowercaseString isEqualToString:@"testapp"]) {
        return NSLocalizedString(@"Мы постараемся приготовить к %@", nil);
    } else {
        return NSLocalizedString(@"Готов к %@", nil);
    }
}

+ (NSString *)db_readyOrderCellString {
    return NSLocalizedString(@"Готов к %@", nil);
}

+ (NSString *)db_bgImageName {
    float screenHeight = [UIScreen mainScreen].nativeBounds.size.height;
    NSString *backImage = [NSString stringWithFormat:@"bg%.0f.jpg", screenHeight];
    
    if (![UIImage imageNamed:backImage]) {
        backImage = @"bg.jpg";
    }
    
    if ([[ApplicationConfig db_bundleName].lowercaseString isEqualToString:@"osteriabianka"]) {
        backImage = @"osteria_bg.jpg";
    }
    
    return backImage;
}

+ (NSString *)db_shareBgImageName {
    NSString *imageName = @"share";
    
    if ([[ApplicationConfig db_bundleName].lowercaseString isEqualToString:@"redcup"]) {
        imageName = @"share_redcup";
    }
    
    if ([[ApplicationConfig db_bundleName].lowercaseString isEqualToString:@"coffeeacademy"]) {
        imageName = @"share_coffeeacademy";
    }
    
    if ([[ApplicationConfig db_bundleName].lowercaseString isEqualToString:@"voda"]) {
        imageName = @"share_voda";
    }
    
    return imageName;
}

+ (UIColor *)db_shareScreenTextColor {
    UIColor *color = [UIColor blackColor];
    
//    if ([[ApplicationConfig db_bundleName].lowercaseString isEqualToString:@"voda"]) {
//        color = [UIColor blackColor];
//    }
    
    return color;
}

+ (NSString *)db_initialMenuTitle {
    if ([DBCompanyInfo sharedInstance].type == DBCompanyTypeMobileShop) {
        return NSLocalizedString(@"Каталог", nil);
    } else {
        return NSLocalizedString(@"Меню", nil);
    }
}

@end
