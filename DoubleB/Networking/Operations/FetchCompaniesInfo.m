//
//  FetchCompaniesInfo.m
//  
//
//  Created by Balaban Alexander on 24/08/15.
//
//

#import "FetchCompaniesInfo.h"

#import "DBCompaniesManager.h"

@implementation FetchCompaniesInfo

- (instancetype)initWithUserInfo:(NSDictionary *)userInfo {
    self = [self init];
    return self;
}

- (void)main {
    if (self.cancelled) return;
    
    [self setState:OperationExecuting];
    [[DBCompaniesManager sharedInstance] requestCompanies:^(BOOL success, NSArray *companies) {
        if (success) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kDBConcurrentOperationCompaniesLoadSuccess object:nil userInfo:@{@"class": NSStringFromClass([self class])}];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kDBConcurrentOperationCompaniesLoadFailure object:nil userInfo:@{@"class": NSStringFromClass([self class])}];
        }
        [self setState:OperationFinished];
    }];
}

@end
