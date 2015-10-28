//
//  FetchCompanyInfo.m
//  
//
//  Created by Balaban Alexander on 24/08/15.
//
//

#import "FetchCompanyInfo.h"

#import "DBCompanyInfo.h"

@implementation FetchCompanyInfo

- (instancetype)initWithUserInfo:(NSDictionary *)userInfo {
    self = [self init];
    return self;
}

- (void)main {
    if (self.cancelled) return;
    
    [self setState:OperationExecuting];
    [[DBCompanyInfo sharedInstance] updateInfo:^(BOOL success) {
        if (success) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kDBConcurrentOperationCompanyInfoLoadSuccess object:nil userInfo:@{@"class": NSStringFromClass([self class])}];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kDBConcurrentOperationCompanyInfoLoadFailure object:nil userInfo:@{@"class": NSStringFromClass([self class])}];
        }
        [self setState:OperationFinished];
    }];
}

@end
