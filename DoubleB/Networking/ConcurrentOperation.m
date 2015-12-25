//
//  ConcurrentOperation.m
//  
//
//  Created by Balaban Alexander on 24/08/15.
//
//

#import "ConcurrentOperation.h"

#pragma mark - CompanyInfo Operation
NSString * __nonnull const kDBConcurrentOperationCompanyInfoLoadSuccess = @"kDBConcurrentOperationCompanyInfoLoadSuccess";
NSString * __nonnull const kDBConcurrentOperationCompanyInfoLoadFailure = @"kDBConcurrentOperationCompanyInfoLoadFailure";
#pragma mark - Companies Operation
NSString * __nonnull const kDBConcurrentOperationCompaniesLoadSuccess = @"kDBConcurrentOperationCompaniesLoadSuccess";
NSString * __nonnull const kDBConcurrentOperationCompaniesLoadFailure = @"kDBConcurrentOperationCompaniesLoadFailure";
#pragma mark - Checkorder Operation
NSString * __nonnull const kDBConcurrentOperationCheckOrderSuccess = @"kDBConcurrentOperationCheckOrderSuccess";
NSString * __nonnull const kDBConcurrentOperationCheckOrderFailure = @"kDBConcurrentOperationCheckOrderFailure";
NSString * __nonnull const kDBConcurrentOperationCheckOrderStarted = @"kDBConcurrentOperationCheckOrderStarted";
NSString * __nonnull const kDBConcurrentOperationCheckOrderStartFailed = @"kDBConcurrentOperationCheckOrderStartFailed";
#pragma mark - FetchVenue Operation
NSString * __nonnull const kDBConcurrentOperationFetchVenuesFinished = @"kDBConcurrentOperationFetchVenuesFinished";
#pragma mark - Subscription Operation
NSString * __nonnull const kDBConcurrentOperationFetchSubscriptionInfoSuccess = @"kDBConcurrentOperationFetchSubscriptionInfoSuccess";
NSString * __nonnull const kDBConcurrentOperationFetchSubscriptionInfoFailure = @"kDBConcurrentOperationFetchSubscriptionInfoFailure";
#pragma mark - FetchAppConfig Operation
NSString * __nonnull const kDBConcurrentOperationAppConfigLoadSuccess = @"kDBConcurrentOperationAppConfigLoadSuccess";
NSString * __nonnull const kDBConcurrentOperationAppConfigLoadFailure = @"kDBConcurrentOperationAppConfigLoadFailure";


#pragma mark - FetchUnifiedCities Operation
NSString * __nonnull const kDBConcurrentOperationUnifiedCitiesLoadSuccess = @"kDBConcurrentOperationUnifiedCitiesLoadSuccess";
NSString * __nonnull const kDBConcurrentOperationUnifiedCitiesLoadFailure = @"kDBConcurrentOperationUnifiedCitiesLoadFailure";
#pragma mark - FetchUnifiedVenues Operation
NSString * __nonnull const kDBConcurrentOperationUnifiedVenuesLoadSuccess = @"kDBConcurrentOperationUnifiedVenuesLoadSuccess";
NSString * __nonnull const kDBConcurrentOperationUnifiedVenuesLoadFailure = @"kDBConcurrentOperationUnifiedVenuesLoadFailure";
#pragma mark - FetchUnifiedMenu Operation
NSString * __nonnull const kDBConcurrentOperationUnifiedMenuLoadSuccess = @"kDBConcurrentOperationUnifiedMenuLoadSuccess";
NSString * __nonnull const kDBConcurrentOperationUnifiedMenuLoadFailure = @"kDBConcurrentOperationUnifiedMenuLoadFailure";

@implementation ConcurrentOperation

- (instancetype)init {
    self = [super init];
    self.state = OperationReady;
    self.notifyOnCompletion = YES;
    return self;
}

- (instancetype)initWithUserInfo:(NSDictionary *)userInfo {
    self = [self init];
    return self;
}

- (BOOL)isReady {
    return super.ready && self.state == OperationReady;
}

- (BOOL)isExecuting {
    return self.state == OperationExecuting;
}

- (BOOL)isFinished {
    return self.state == OperationFinished;
}

- (BOOL)isAsynchronous {
    return YES;
}

- (void)setState:(ConcurrentOperationState)state {
    NSString *oldStatus = [self statusForState:self.state];
    NSString *statusForState = [self statusForState:state];
    [self willChangeValueForKey:oldStatus];
    [self willChangeValueForKey:statusForState];
    _state = state;
    [self didChangeValueForKey:oldStatus];
    [self didChangeValueForKey:statusForState];
}

- (NSString *)statusForState:(ConcurrentOperationState)state {
    return @{
             @(OperationReady): @"isReady",
             @(OperationExecuting): @"isExecuting",
             @(OperationFinished): @"isFinished"
             }[@(state)];
}

- (void)start {
    if (self.cancelled) {
        [self setState:OperationFinished];
    } else {
        [self main];
        [self setState:OperationExecuting];
    }
}

@end
