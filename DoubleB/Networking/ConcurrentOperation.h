//
//  ConcurrentOperation.h
//  
//
//  Created by Balaban Alexander on 24/08/15.
//
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    OperationReady,
    OperationExecuting,
    OperationFinished,
} ConcurrentOperationState;

@interface ConcurrentOperation : NSOperation

@property (nonatomic) ConcurrentOperationState state;
@property (nonatomic, weak) NSOperationQueue *queue;

@end
