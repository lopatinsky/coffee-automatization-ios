//
//  PosUserActivity.h
//  DoubleB
//
//  Created by Balaban Alexander on 16/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "ConcurrentOperation.h"
#import "AppIndexingManager.h"

@interface PostUserActivity : ConcurrentOperation

- (nonnull instancetype)initWithObject:(nonnull id<UserActivityIndexing>)obj andParams:(nonnull NSDictionary *)params;

@end
