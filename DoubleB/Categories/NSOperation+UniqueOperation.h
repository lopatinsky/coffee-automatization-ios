//
//  NSOperation+UniqueOperation.h
//  
//
//  Created by Balaban Alexander on 24/08/15.
//
//

#import <Foundation/Foundation.h>

@interface NSOperationQueue (UniqueOperation)

- (BOOL)addUniqueOperation:(NSOperation *)operation;

@end
