//
//  NetworkManager.m
//  
//
//  Created by Balaban Alexander on 24/08/15.
//
//

#import "NetworkManager.h"
#import "NSOperation+UniqueOperation.h"

#define MAX_REPEATS 3

NSString *const kDBNetworkManagerConnectionFailed = @"kDBNetworkManagerConnectionFailed";
NSString *const kDBNetworkManagerShouldRetryToRequest = @"kDBNetworkManagerShouldRetryToRequest";

@interface NetworkManager()

@property (nonatomic, strong) NSMutableDictionary *errorsHandler;

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
        self.errorsHandler = [NSMutableDictionary new];
        [self subscribeOnNetworkFailureEvents];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(retryOperations) name:kDBNetworkManagerShouldRetryToRequest object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)subscribeOnNetworkFailureEvents {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionFailed:) name:kDBConcurrentOperationCompaniesLoadFailure object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionFailed:) name:kDBConcurrentOperationCompanyInfoLoadFailure object:nil];
}

- (void)retryOperations {
    for (NSString *key in [self.errorsHandler allKeys]) {
        if ([[self.errorsHandler objectForKey:key] integerValue] == MAX_REPEATS) {
            [self.operationQueue addConcurrentPendingOperation:[NSClassFromString(key) new]];
            [self.errorsHandler setObject:@(1) forKey:key];
        }
    }
}

- (void)connectionFailed:(NSNotification *)notification {
    NSString *opClass = [notification userInfo][@"class"];
    
    if ([self.errorsHandler objectForKey:opClass]) {
        NSInteger numOfErrors = [[self.errorsHandler objectForKey:opClass] integerValue];
        [self.errorsHandler setObject:@(++numOfErrors) forKey:opClass];
        if (numOfErrors == MAX_REPEATS) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kDBNetworkManagerConnectionFailed object:nil];
        } else {
            [self.operationQueue addConcurrentPendingOperation:[NSClassFromString(opClass) new]];
        }
    } else {
        [self.errorsHandler setObject:@(1) forKey:opClass];
        [self.operationQueue addConcurrentPendingOperation:[NSClassFromString(opClass) new]];
    }
}

- (void)setOperationQueue:(NSOperationQueue *)operationQueue {
    _operationQueue = operationQueue;
}

- (void)addPendingUniqueOperation:(NetworkOperation)opType {
    [self addPendingUniqueOperation:opType withUserInfo:nil];
}

- (void)addPendingUniqueOperation:(NetworkOperation)opType withUserInfo:(NSDictionary *)userInfo {
    ConcurrentOperation *op = [NetworkManager operationWithType:opType andUserInfo:userInfo];
    [self.operationQueue addConcurrentPendingUniqueOperation:op];
}

- (void)addUniqueOperation:(NetworkOperation)opType {
    [self addUniqueOperation:opType withUserInfo:nil];
}

- (void)addUniqueOperation:(NetworkOperation)opType withUserInfo:(NSDictionary *)userInfo {
    ConcurrentOperation *operation = [NetworkManager operationWithType:opType andUserInfo:userInfo];
    [self.operationQueue addConcurrentUniqueOperation:operation];
}

- (void)addPendingOperation:(NetworkOperation)opType {
    [self addPendingOperation:opType withUserInfo:nil];
}

- (void)addPendingOperation:(NetworkOperation)opType withUserInfo:(NSDictionary *)userInfo {
    ConcurrentOperation *op = [NetworkManager operationWithType:opType andUserInfo:userInfo];
    [self.operationQueue addConcurrentPendingOperation:op];
}

- (void)addOperation:(NetworkOperation)opType {
    [self addOperation:opType withUserInfo:nil];
}

- (void)addOperation:(NetworkOperation)opType withUserInfo:(NSDictionary *)userInfo {
    ConcurrentOperation *operation = [NetworkManager operationWithType:opType andUserInfo:userInfo];
    [self.operationQueue addConcurrentOperation:operation];
}

- (void)forceAddOperation:(NetworkOperation)opType {
    ConcurrentOperation *operation = [NetworkManager operationWithType:opType andUserInfo:nil];
    [self.operationQueue forceAddConcurrentUniqueOperation:operation];
}

@end

#import "FetchCompanyInfo.h"
#import "FetchCompaniesInfo.h"
#import "CheckOrder.h"
#import "FetchVenues.h"
#import "FetchSubscriptionData.h"
#import "FetchUnifiedCities.h"
#import "FetchUnifiedMenu.h"
#import "FetchUnifiedVenues.h"
@implementation NetworkManager(OperationLoader)

+ (ConcurrentOperation *)operationWithType:(NetworkOperation)type {
    return [NetworkManager operationWithType:type andUserInfo:nil];
}

+ (ConcurrentOperation *)operationWithType:(NetworkOperation)type andUserInfo:(NSDictionary *)userInfo {
    NSDictionary *operationClasses = @{
                                       @(NetworkOperationFetchCompanyInfo): [FetchCompanyInfo class],
                                       @(NetworkOperationFetchCompanies): [FetchCompaniesInfo class],
                                       @(NetworkOperationCheckOrder): [CheckOrder class],
                                       @(NetworkOperationFetchVenues): [FetchVenues class],
                                       @(NetworkOperationFetchSubscriptionInfo): [FetchSubscriptionData class],
                                       @(NetworkOperationFetchUnifiedCities): [FetchUnifiedCities class],
                                       @(NetworkOperationFetchUnifiedMenu): [FetchUnifiedMenu class],
                                       @(NetworkOperationFetchUnifiedVenues): [FetchUnifiedVenues class]
                                       };
    ConcurrentOperation *operation = [[[operationClasses objectForKey:@(type)] alloc] initWithUserInfo:userInfo];
    operation.queue = [NetworkManager sharedManager].operationQueue;
    return operation;
}

@end