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
    self.name = NSStringFromClass([self class]);
    self.state = OperationReady;
    return self;
}

- (BOOL)isReady {
    return super.ready && self.state == OperationReady;
}

- (BOOL)isExecuting {
    return self.state == OperationExecuting;
}

- (BOOL)isFinished {
    return self.state == OperationFinished;
}

- (BOOL)isAsynchronous {
    return YES;
}

- (void)setState:(ConcurrentOperationState)state {
    NSString *oldStatus = [self statusForState:self.state];
    NSString *statusForState = [self statusForState:state];
    [self willChangeValueForKey:oldStatus];
    [self willChangeValueForKey:statusForState];
    _state = state;
    [self didChangeValueForKey:oldStatus];
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
        [self main];
        [self setState:OperationExecuting];
    }
}

@end
