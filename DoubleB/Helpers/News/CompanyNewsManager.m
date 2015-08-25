//
//  CompanyNewsManager.m
//  
//
//  Created by Balaban Alexander on 25/08/15.
//
//

#import "CompanyNewsManager.h"
#import "DBServerAPI.h"

NSString *const CompanyNewsManagerDidFetchActualNews = @"CompanyNewsManagerDidFetchActualNews";

@implementation CompanyNewsManager

+ (instancetype)sharedManager {
    static CompanyNewsManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [CompanyNewsManager new];
    });
    return instance;
}

- (void)fetchUpdates {
    [DBServerAPI fetchCompanyNewsWithCallback:^(BOOL success, NSDictionary *response) {
        NSArray *news = [response objectForKey:@"news"];
        if ([news count] > 0) {
            NSDictionary *newsDictionary = [news firstObject];
            NSNumber *fetchedNewsId = @([[newsDictionary objectForKey:@"id"] integerValue]);
            NSNumber *lastNewsId = [[NSUserDefaults standardUserDefaults] objectForKey:@"ACTUAL_NEWS_ID"] ?: @(-1);
            if (![fetchedNewsId isEqualToNumber:lastNewsId]) {
                [[NSUserDefaults standardUserDefaults] setObject:fetchedNewsId forKey:@"ACTUAL_NEWS_ID"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                self.actualNews = [CompanyNews new];
                self.actualNews.newsId = fetchedNewsId;
                self.actualNews.imageURL = [newsDictionary objectForKey:@"image_url"];
                self.actualNews.text = [newsDictionary objectForKey:@"text"];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:CompanyNewsManagerDidFetchActualNews object:nil];
            }
        }
    }];
}

@end
