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

- (void)main {
    if (self.cancelled) return;
    
    [[DBCompanyInfo sharedInstance] updateInfo:^(BOOL success) {
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
