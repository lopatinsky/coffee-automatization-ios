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

- (void)main {
    if (self.cancelled) return;
    
    [[DBCompaniesManager sharedInstance] requestCompanies:^(BOOL success, NSArray *companies) {
        if (self.queue.operations.count == 1) {
            if (success) {
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kDBApplicationManagerInfoLoadSuccess object:nil]];
            } else {
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kDBApplicationManagerInfoLoadFailure object:nil]];
            }
        }
        [self setState:OperationFinished];
    }];
}

@end
