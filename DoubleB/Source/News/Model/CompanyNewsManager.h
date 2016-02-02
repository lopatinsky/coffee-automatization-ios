//
//  CompanyNewsManager.h
//  
//
//  Created by Balaban Alexander on 25/08/15.
//
//

#import <Foundation/Foundation.h>
#import "CompanyNews.h"

extern NSString *const CompanyNewsManagerDidFetchActualNews;
extern NSString *const CompanyNewsManagerDidReceiveNewsPush;

@interface CompanyNewsManager : NSObject
@property (nonatomic) BOOL available;

@property (nonatomic, strong) CompanyNews *actualNews;
@property (nonatomic, strong) NSArray *allNews;

+ (instancetype)sharedManager;

- (void)fetchUpdates;

@end
