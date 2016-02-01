//
//  NSOperation+UniqueOperation.h
//  
//
//  Created by Balaban Alexander on 24/08/15.
//
//

#import <Foundation/Foundation.h>

@interface NSOperationQueue (UniqueOperation)

- (BOOL)addConcurrentUniqueOperation:(NSOperation *)operation;
- (BOOL)addConcurrentPendingUniqueOperation:(NSOperation *)operation;
- (void)addConcurrentPendingOperation:(NSOperation *)operation;
- (void)addConcurrentOperation:(NSOperation *)operation;
- (void)forceAddConcurrentUniqueOperation:(NSOperation *)operation;

@end
