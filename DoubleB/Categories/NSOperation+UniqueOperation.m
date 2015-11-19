//
//  NSOperation+UniqueOperation.m
//  
//
//  Created by Balaban Alexander on 24/08/15.
//
//

#import "NSOperation+UniqueOperation.h"

#import "ConcurrentOperation.h"

@implementation NSOperationQueue (UniqueOperation)

- (BOOL)addConcurrentUniqueOperation:(NSOperation *)operation {
//    NSLog(@"%s %@\n%@", __PRETTY_FUNCTION__, NSStringFromClass([operation class]), self.operations);
    NSArray *ops = self.operations;
    BOOL exists = NO;
    
    for (NSOperation *op in ops) {
        BOOL same = object_getClassName(op) == object_getClassName(operation);
        if (same) {
            exists = YES;
            break;
        }
    }
    
    if (!exists) {
        [self addOperation:operation];
    }
    
    return exists;
}

- (BOOL)addConcurrentPendingUniqueOperation:(NSOperation *)operation {
//    NSLog(@"%s %@\n%@", __PRETTY_FUNCTION__, NSStringFromClass([operation class]), self.operations);
    if (self.operations.count > 0) {
        [operation addDependency:self.operations.lastObject];
    }
    return [self addConcurrentUniqueOperation:operation];
}

- (void)addConcurrentPendingOperation:(NSOperation *)operation {
//    NSLog(@"%s %@\n%@", __PRETTY_FUNCTION__, NSStringFromClass([operation class]), self.operations);
    
    NSOperation *lastOp = nil;
    for (NSOperation *op in self.operations) {
        if ([op class] == [operation class]) {
            lastOp = op;
        }
    }
    
    if (lastOp) {
        [operation addDependency:lastOp];
    }
    
    [self addOperation:operation];
}

- (void)addConcurrentOperation:(NSOperation *)operation {
//    NSLog(@"%s %@\n%@", __PRETTY_FUNCTION__, NSStringFromClass([operation class]), self.operations);
    [self addOperation:operation];
}

- (void)forceAddConcurrentUniqueOperation:(NSOperation *)operation {
//    NSLog(@"%s %@\n%@", __PRETTY_FUNCTION__, NSStringFromClass([operation class]), self.operations);
    NSArray *ops = self.operations;
    NSOperation *oper = nil;
    
    for (NSOperation *op in ops) {
        BOOL same = object_getClassName(op) == object_getClassName(operation);
        if (same) {
            if (!op.executing) {
                [op cancel];
            } else {
                oper = op;
            }
        }
    }
    
    if (oper) {
        [operation addDependency:oper];
        ConcurrentOperation *cop = (ConcurrentOperation *)oper;
        cop.notifyOnCompletion = NO;
    }
    [self addOperation:operation];
}

@end
