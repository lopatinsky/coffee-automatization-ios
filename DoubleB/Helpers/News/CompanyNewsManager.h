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

@interface CompanyNewsManager : NSObject

@property (nonatomic, strong) CompanyNews *actualNews;

+ (instancetype)sharedManager;

- (void)fetchUpdates;

@end
