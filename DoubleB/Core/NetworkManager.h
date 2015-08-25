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
    FetchCompaniesOperation,
    FetchCompanyInfoOperation,
} NetworkOperation;

@interface NetworkManager : NSObject

+ (instancetype)sharedManager;

- (void)setOperationQueue:(NSOperationQueue *)queue;
- (void)addUniqueOperation:(NetworkOperation)operation;
- (void)addOperation:(NetworkOperation)operation;

@end

@interface NetworkManager(OperationLoader)

+ (ConcurrentOperation *)operationWithType:(NetworkOperation)type;

@end