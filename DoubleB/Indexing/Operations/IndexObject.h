//
//  IndexObject.h
//  DoubleB
//
//  Created by Balaban Alexander on 16/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "ConcurrentOperation.h"
#import "AppIndexingManager.h"

@interface IndexObject : ConcurrentOperation

- (nonnull instancetype)initWithObject:(nonnull id<SpotlightIndexing>)obj andParams:(nonnull NSDictionary *)params;

@end
