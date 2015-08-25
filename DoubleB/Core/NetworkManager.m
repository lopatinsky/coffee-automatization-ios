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
    _operationQueue = operationQueue;
}

- (void)addUniqueOperation:(NetworkOperation)opType {
    ConcurrentOperation *operation = [NetworkManager operationWithType:opType];
    if (self.operationQueue.operations.count > 0) {
        [operation addDependency:self.operationQueue.operations.lastObject];
    }
    [self.operationQueue addUniqueOperation:operation];
}

- (void)addOperation:(NetworkOperation)opType {
    ConcurrentOperation *operation = [NetworkManager operationWithType:opType];
    if (self.operationQueue.operations.count > 0) {
        [operation addDependency:self.operationQueue.operations.lastObject];
    }
    [self.operationQueue addOperation:operation];
}

@end

#import "FetchCompanyInfo.h"
#import "FetchCompaniesInfo.h"
@implementation NetworkManager(OperationLoader)

+ (ConcurrentOperation *)operationWithType:(NetworkOperation)type {
    ConcurrentOperation *operation = @{
        @(FetchCompaniesOperation): [FetchCompaniesInfo new],
        @(FetchCompanyInfoOperation): [FetchCompanyInfo new]
    }[@(type)];
    operation.queue = [NetworkManager sharedManager].operationQueue;
    return operation;
}

@end