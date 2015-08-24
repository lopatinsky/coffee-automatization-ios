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

- (BOOL)asynchronous {
    return YES;
}

- (void)start {
    if (self.cancelled) {
        self.state = OperationFinished;
    } else {
        [self main];
        self.state = OperationExecuting;
    }
}

@end
