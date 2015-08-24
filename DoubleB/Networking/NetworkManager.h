//
//  NetworkManager.h
//  
//
//  Created by Balaban Alexander on 24/08/15.
//
//

#import <Foundation/Foundation.h>

@interface NetworkManager : NSObject


+ (instancetype)sharedManager;

- (void)setOperationQueue:(NSOperationQueue *)queue;
- (void)addUniqueOperation:(NSOperation *)operation;
- (void)addOperation:(NSOperation *)operation;

@end
