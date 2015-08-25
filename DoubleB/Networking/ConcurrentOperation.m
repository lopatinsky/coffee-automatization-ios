//
//  ConcurrentOperation.m
//  
//
//  Created by Balaban Alexander on 24/08/15.
//
//

#import "ConcurrentOperation.h"

@implementation ConcurrentOperation

- (instancetype)init {
    self = [super init];
    self.state = OperationReady;
    return self;
}

- (BOOL)ready {
    return super.ready && self.state == OperationReady;
}

- (BOOL)executing {
    return self.state == OperationExecuting;
}

- (BOOL)finished {
    return self.state == OperationFinished;
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isAsynchronous {
    return YES;
}

- (void)setState:(ConcurrentOperationState)state {
    NSString *statusForState = [self statusForState:state];
    NSLog(@"%@ %@", self, statusForState);
    [self willChangeValueForKey:statusForState];
    _state = state;
    [self didChangeValueForKey:statusForState];
}

- (NSString *)statusForState:(ConcurrentOperationState)state {
    return @{
             @(OperationReady): @"isReady",
             @(OperationExecuting): @"isExecuting",
             @(OperationFinished): @"isFinished"
             }[@(state)];
}

- (void)start {
    if (self.cancelled) {
        [self setState:OperationFinished];
    } else {
        [self setState:OperationExecuting];
        [self main];
    }
}

@end
