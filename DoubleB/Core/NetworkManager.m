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

- (void)addPendingUniqueOperation:(NetworkOperation)opType {
    ConcurrentOperation *op = [NetworkManager operationWithType:opType];
    if ([self.operationQueue operationCount] > 0) {
        [op addDependency:[[self.operationQueue operations] lastObject]];
    }
    [self.operationQueue addUniqueOperation:op];
}

- (void)addUniqueOperation:(NetworkOperation)opType {
    ConcurrentOperation *operation = [NetworkManager operationWithType:opType];
    [self.operationQueue addUniqueOperation:operation];
}

- (void)addPendingOperation:(NetworkOperation)opType {
    ConcurrentOperation *op = [NetworkManager operationWithType:opType];
    if ([self.operationQueue operationCount] > 0) {
        [op addDependency:[[self.operationQueue operations] lastObject]];
    }
    [self.operationQueue addOperation:op];
}

- (void)addOperation:(NetworkOperation)opType {
    ConcurrentOperation *operation = [NetworkManager operationWithType:opType];
    [self.operationQueue addOperation:operation];
}

- (void)addOperationsWithDependance:(NSArray *)operations {
    NSMutableArray *ops = [NSMutableArray new];
    for (NSNumber *opType in operations) {
        [ops addObject:[NetworkManager operationWithType:opType.integerValue]];
    }
    for (NSUInteger i = 1; i < [ops count]; ++i) {
        [[ops objectAtIndex:i] addDependency:[ops objectAtIndex:i - 1]];
    }
    [self.operationQueue addOperations:ops waitUntilFinished:NO];
}

@end

#import "FetchCompanyInfo.h"
#import "FetchCompaniesInfo.h"
@implementation NetworkManager(OperationLoader)

+ (ConcurrentOperation *)operationWithType:(NetworkOperation)type {
    NSDictionary *operationClasses = @{
                                       @(NetworkOperationFetchCompanyInfo): [FetchCompanyInfo class],
                                       @(NetworkOperationFetchCompanies): [FetchCompaniesInfo class]
                                       };
    NSLog(@"OPERATION TYPE: %@", [operationClasses objectForKey:@(type)]);
    ConcurrentOperation *operation = [[operationClasses objectForKey:@(type)] new];
    operation.queue = [NetworkManager sharedManager].operationQueue;
    return operation;
}

@end