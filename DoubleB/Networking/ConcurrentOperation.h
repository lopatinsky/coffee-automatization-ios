//
//  ConcurrentOperation.h
//  
//
//  Created by Balaban Alexander on 24/08/15.
//
//

#import <Foundation/Foundation.h>

#pragma mark - CompanyInfo Operation
extern NSString * __nonnull const kDBConcurrentOperationCompanyInfoLoadSuccess;
extern NSString * __nonnull const kDBConcurrentOperationCompanyInfoLoadFailure;
#pragma mark - Companies Operation
extern NSString * __nonnull const kDBConcurrentOperationCompaniesLoadSuccess;
extern NSString * __nonnull const kDBConcurrentOperationCompaniesLoadFailure;
#pragma mark - CheckOrder Operation
extern NSString * __nonnull const kDBConcurrentOperationCheckOrderSuccess;
extern NSString * __nonnull const kDBConcurrentOperationCheckOrderFailure;
extern NSString * __nonnull const kDBConcurrentOperationCheckOrderStarted;
extern NSString * __nonnull const kDBConcurrentOperationCheckOrderStartFailed;
#pragma mark - FetchVenue Operation
extern NSString * __nonnull const kDBConcurrentOperationFetchVenuesFinished;
#pragma mark - Subscription Operation
extern NSString * __nonnull const kDBConcurrentOperationFetchSubscriptionInfoSuccess;
extern NSString * __nonnull const kDBConcurrentOperationFetchSubscriptionInfoFailure;
#pragma mark - FetchAppConfig Operation
extern NSString * __nonnull const kDBConcurrentOperationAppConfigLoadSuccess;
extern NSString * __nonnull const kDBConcurrentOperationAppConfigLoadFailure;

#pragma mark - FetchUnifiedCities Operation
extern NSString * __nonnull const kDBConcurrentOperationUnifiedCitiesLoadSuccess;
extern NSString * __nonnull const kDBConcurrentOperationUnifiedCitiesLoadFailure;
#pragma mark - FetchUnifiedVenues Operation
extern NSString * __nonnull const kDBConcurrentOperationUnifiedVenuesLoadSuccess;
extern NSString * __nonnull const kDBConcurrentOperationUnifiedVenuesLoadFailure;
#pragma mark - FetchUnifiedMenu Operation
extern NSString * __nonnull const kDBConcurrentOperationUnifiedMenuLoadSuccess;
extern NSString * __nonnull const kDBConcurrentOperationUnifiedMenuLoadFailure;

typedef enum : NSUInteger {
    OperationReady,
    OperationExecuting,
    OperationFinished,
} ConcurrentOperationState;

@protocol CustomizableOperation <NSObject>

- (nonnull instancetype)initWithUserInfo:(nullable NSDictionary *)userInfo;

@end

@interface ConcurrentOperation : NSOperation<CustomizableOperation>

@property (nonatomic) BOOL notifyOnCompletion;
@property (nonatomic) ConcurrentOperationState state;
@property (nonatomic, weak) NSOperationQueue *queue;

- (BOOL)isReady;
- (BOOL)isExecuting;
- (BOOL)isFinished;

@end
