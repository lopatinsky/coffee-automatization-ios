//
//  CompanyNewsManager.m
//  
//
//  Created by Balaban Alexander on 25/08/15.
//
//

#import "CompanyNewsManager.h"
#import "UIViewController+DBAppearance.h"
#import "DBServerAPI.h"

NSString *const CompanyNewsManagerDidFetchActualNews = @"CompanyNewsManagerDidFetchActualNews";
NSString *const CompanyNewsManagerDidReceiveNewsPush = @"CompanyNewsManagerDidReceiveNewsPush";

@interface CompanyNewsManager()

@property (nonatomic, strong) UIWindow *newsWindow;

@end

@implementation CompanyNewsManager

+ (instancetype)sharedManager {
    static CompanyNewsManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [CompanyNewsManager new];
        [instance updateNews:[[NSUserDefaults standardUserDefaults] objectForKey:@"kCompanyNewsManager_allNews"] ?: @[]];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateNews:(NSArray *)newsArray {
    NSArray *oldNews = [[NSUserDefaults standardUserDefaults] objectForKey:@"kCompanyNewsManager_allNews"] ?: @[];
    NSMutableArray *news = [NSMutableArray new];
    for (NSDictionary *newsDictionary in newsArray) {
        CompanyNews *companyNews = [CompanyNews new];
        companyNews.newsId = [newsDictionary objectForKey:@"id"];
        companyNews.imageURL = [newsDictionary objectForKey:@"image_url"];
        companyNews.text = [newsDictionary objectForKey:@"text"];
        companyNews.title = [newsDictionary objectForKey:@"title"];
        companyNews.date = [NSDate dateWithTimeIntervalSince1970:[[newsDictionary objectForKey:@"start"] longLongValue]];
        [news addObject:companyNews];
    }
    
    NSMutableArray *newNews = [NSMutableArray new];
    for (CompanyNews *cNews in news) {
        BOOL hasNews = NO;
        for (NSDictionary *_news in oldNews) {
            if ([[_news objectForKey:@"id"] compare:[cNews newsId]] == NSOrderedSame) {
                hasNews = YES;
            }
        }
        if (!hasNews) {
            [newNews addObject:cNews];
        }
    }
    
    if ([newNews count] > 0) {
        NSArray *_newNews = [newNews sortedArrayUsingComparator:^NSComparisonResult(CompanyNews * _Nonnull obj1, CompanyNews * _Nonnull obj2) {
            return [[obj2 date] compare:[obj1 date]];
        }];
        
        CompanyNews *actualNews = [_newNews firstObject];
        UIViewController<PopupNewsViewControllerProtocol> *newsViewController = [ViewControllerManager newsViewController];
        [newsViewController setData:@{@"title": [actualNews title] ?: @"",
                                      @"text": [actualNews text] ?: @"",
                                      @"image_url": [actualNews imageURL] ?: @""}];
        [[UIViewController currentViewController] presentViewController:newsViewController animated:YES completion:nil];
    }
    
    self.allNews = news;
    self.actualNews = [news firstObject];
}

- (void)fetchUpdates {
    [DBServerAPI fetchCompanyNewsWithCallback:^(BOOL success, NSDictionary *response) {
        NSArray *news = [response objectForKey:@"news"];
        
        news = [news sortedArrayUsingComparator:^NSComparisonResult(NSDictionary * _Nonnull obj1, NSDictionary * _Nonnull obj2) {
            return [obj2[@"start"] compare:obj1[@"start"]];
        }];
        if ([news count] > 0) {
            [self updateNews:news];
            [[NSNotificationCenter defaultCenter] postNotificationName:CompanyNewsManagerDidFetchActualNews object:nil];
        }
        [[NSUserDefaults standardUserDefaults] setObject:news forKey:@"kCompanyNewsManager_allNews"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
}

- (void)showNews {
    UIViewController<PopupNewsViewControllerProtocol> *newsViewController = [ViewControllerManager newsViewController];
    CompanyNews *actualNews = [[CompanyNewsManager sharedManager] actualNews];
    [newsViewController setData:@{@"text": [actualNews text], @"image_url": [actualNews imageURL]}];
    [[UIViewController currentViewController] presentViewController:newsViewController animated:YES completion:^{
        
    }];
}

@end