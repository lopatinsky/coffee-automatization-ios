//
//  NetworkManager.m
//  
//
//  Created by Balaban Alexander on 24/08/15.
//
//

#import "NetworkManager.h"

#import "NSOperation+UniqueOperation.h"

@interface NetworkManager()

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation NetworkManager

+ (instancetype)sharedManager {
    static NetworkManager *instance = nil;
    static dispatch_once_t token = 0;
    
    dispatch_once(&token, ^{
        instance = [[NetworkManager alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.operationQueue = [NSOperationQueue new];
        self.operationQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)setOperationQueue:(NSOperationQueue *)operationQueue {
    self.operationQueue = operationQueue;
}

- (void)addUniqueOperation:(NSOperation *)operation {
    [self.operationQueue addUniqueOperation:operation];
}

- (void)addOperation:(NSOperation *)operation {
    [self.operationQueue addOperation:operation];
}

@end
