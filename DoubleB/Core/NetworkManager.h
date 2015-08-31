//
//  NetworkManager.h
//  
//
//  Created by Balaban Alexander on 24/08/15.
//
//

#import <Foundation/Foundation.h>
#import "ConcurrentOperation.h"

typedef enum : NSUInteger {
    NetworkOperationFetchCompanies = 0,
    NetworkOperationFetchCompanyInfo,
} NetworkOperation;

@interface NetworkManager : NSObject

@property (nonatomic, strong) NSOperationQueue *operationQueue;

+ (instancetype)sharedManager;

- (void)setOperationQueue:(NSOperationQueue *)queue;
- (void)addPendingUniqueOperation:(NetworkOperation)operation;
- (void)addUniqueOperation:(NetworkOperation)operation;
- (void)addPendingOperation:(NetworkOperation)operation;
- (void)addOperation:(NetworkOperation)operation;
- (void)addOperationsWithDependance:(NSArray *)operations;

@end

@interface NetworkManager(OperationLoader)

+ (ConcurrentOperation *)operationWithType:(NetworkOperation)type;

@end