//
//  NetworkManager.h
//  
//
//  Created by Balaban Alexander on 24/08/15.
//
//

#import <Foundation/Foundation.h>
#import "ConcurrentOperation.h"

extern NSString * __nonnull const kDBNetworkManagerConnectionFailed;
extern NSString * __nonnull const kDBNetworkManagerShouldRetryToRequest;

typedef enum : NSUInteger {
    NetworkOperationFetchCompanies = 0,
    NetworkOperationFetchCompanyInfo,
    NetworkOperationCheckOrder,
    NetworkOperationFetchVenues
} NetworkOperation;

@interface NetworkManager : NSObject

@property (nonatomic, strong) NSOperationQueue * __nonnull operationQueue;

+ (nonnull instancetype)sharedManager;

- (void)setOperationQueue:(nonnull NSOperationQueue *)queue;
- (void)addPendingUniqueOperation:(NetworkOperation)operation;
- (void)addUniqueOperation:(NetworkOperation)operation;
- (void)addPendingOperation:(NetworkOperation)operation;
- (void)addOperation:(NetworkOperation)operation;

- (void)addPendingUniqueOperation:(NetworkOperation)operation withUserInfo:(nullable NSDictionary *)userInfo;
- (void)addUniqueOperation:(NetworkOperation)operation withUserInfo:(nullable NSDictionary *)userInfo;
- (void)addPendingOperation:(NetworkOperation)operation withUserInfo:(nullable NSDictionary *)userInfo;
- (void)addOperation:(NetworkOperation)operation withUserInfo:(nullable NSDictionary *)userInfo;

@end

@interface NetworkManager(OperationLoader)

+ (nonnull ConcurrentOperation *)operationWithType:(NetworkOperation)type;
+ (nonnull ConcurrentOperation *)operationWithType:(NetworkOperation)type andUserInfo:(nullable NSDictionary *)userInfo;

@end