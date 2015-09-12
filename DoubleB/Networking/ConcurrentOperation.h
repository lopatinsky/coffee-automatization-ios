//
//  ConcurrentOperation.h
//  
//
//  Created by Balaban Alexander on 24/08/15.
//
//

#import <Foundation/Foundation.h>

#pragma mark - CompanyInfo Operation
extern NSString *const kDBConcurrentOperationCompanyInfoLoadSuccess;
extern NSString *const kDBConcurrentOperationCompanyInfoLoadFailure;
#pragma mark - Companies Operation
extern NSString *const kDBConcurrentOperationCompaniesLoadSuccess;
extern NSString *const kDBConcurrentOperationCompaniesLoadFailure;
#pragma mark - CheckOrder Operation
extern NSString *const kDBConcurrentOperationCheckOrderSuccess;
extern NSString *const kDBConcurrentOperationCheckOrderFailure;
extern NSString *const kDBConcurrentOperationCheckOrderStarted;
extern NSString *const kDBConcurrentOperationCheckOrderFailed;

typedef enum : NSUInteger {
    OperationReady,
    OperationExecuting,
    OperationFinished,
} ConcurrentOperationState;

@interface ConcurrentOperation : NSOperation

@property (nonatomic) ConcurrentOperationState state;
@property (nonatomic, weak) NSOperationQueue *queue;

- (BOOL)isReady;
- (BOOL)isExecuting;
- (BOOL)isFinished;

@end
