//
//  CompanyNewsManager.m
//  
//
//  Created by Balaban Alexander on 25/08/15.
//
//

#import "CompanyNewsManager.h"
#import "ViewControllerManager.h"
#import "UIViewController+DBAppearance.h"
#import "DBServerAPI.h"

NSString *const CompanyNewsManagerDidFetchActualNews = @"CompanyNewsManagerDidFetchActualNews";

@interface CompanyNewsManager()

@property (nonatomic, strong) UIWindow *newsWindow;

@end

@implementation CompanyNewsManager

+ (instancetype)sharedManager {
    static CompanyNewsManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [CompanyNewsManager new];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNews) name:CompanyNewsManagerDidFetchActualNews object:nil];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void)showNews {
    UIViewController<PopupNewsViewControllerProtocol> *newsViewController = [ViewControllerManager newsViewController];
    CompanyNews *actualNews = [[CompanyNewsManager sharedManager] actualNews];
    [newsViewController setData:@{@"text": [actualNews text], @"image_url": [actualNews imageURL]}];
    [[UIViewController currentViewController] presentViewController:newsViewController animated:YES completion:^{
        
    }];
}

@end
