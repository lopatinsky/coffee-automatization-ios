//
//  AppSearchManager.m
//  
//
//  Created by Balaban Alexander on 08/09/15.
//
//

#import "AppSearchManager.h"
#import "UIDevice+OSVersion.h"

#import <CoreSpotlight/CoreSpotlight.h>
#import <MobileCoreServices/UTCoreTypes.h>

@implementation AppSearchManager

+ (nullable instancetype)sharedManager {
    static AppSearchManager *instance;
    static dispatch_once_t onceToken;
    
    if ([UIDevice systemVersionGreaterThanOrEquals:@"9.0"]) {
        dispatch_once(&onceToken, ^{
            instance = [[AppSearchManager alloc] init];
        });
    }
    
    return instance;
}

- (void)createUserActivity:(id<SearchableProtocol>)searchable {
    NSUserActivity *activity = [[NSUserActivity alloc] initWithActivityType:[searchable activityType]];
    activity.title = @"potato";
    activity.userInfo = [searchable activityUserInfo];
    activity.keywords = [NSSet setWithArray:@[@"potato"]];
    
    CSSearchableItemAttributeSet *attributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(NSString *)kUTTypeText];
    attributeSet.thumbnailData = UIImagePNGRepresentation([UIImage imageNamed:@"visa_icon"]);
    attributeSet.contentDescription = [searchable activityDescription];
    
    activity.eligibleForSearch = YES;
    [activity becomeCurrent];
}

- (void)createPublicUserActivity:(id<SearchableProtocol>)searchable {
    CSSearchableItemAttributeSet *attributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(NSString *)kUTTypeText];
    attributeSet.title = [searchable activityTitle];
    attributeSet.keywords = [searchable activityKeywords];
    attributeSet.contentDescription = [searchable activityDescription];
    
    CSSearchableItem *item = [[CSSearchableItem alloc] initWithUniqueIdentifier:[searchable activityTitle] domainIdentifier:[searchable activityType] attributeSet:attributeSet];
    item.expirationDate = [searchable activityExpirationDate];
    [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:@[item] completionHandler:^(NSError * _Nullable error) {
        
    }];
}

@end
