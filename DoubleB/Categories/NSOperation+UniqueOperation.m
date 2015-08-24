//
//  NSOperation+UniqueOperation.m
//  
//
//  Created by Balaban Alexander on 24/08/15.
//
//

#import "NSOperation+UniqueOperation.h"

@implementation NSOperationQueue (UniqueOperation)

- (BOOL)addUniqueOperation:(NSOperation *)operation {
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

@end
