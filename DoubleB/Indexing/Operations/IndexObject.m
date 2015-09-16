//
//  IndexObject.m
//  DoubleB
//
//  Created by Balaban Alexander on 16/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "IndexObject.h"

@interface IndexObject()

@property (nonatomic, strong) id<SpotlightIndexing> obj;
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, strong) NSUserActivity *activity;

@end

@implementation IndexObject

- (instancetype)initWithObject:(id<SpotlightIndexing>)obj andParams:(NSDictionary *)params {
    self = [super init];
    _obj = obj;
    _params = params;
    return self;
}

- (void)main {
    if (self.cancelled) return;
    CSSearchableItem *item = [[CSSearchableItem alloc] initWithUniqueIdentifier:[self.obj spotlightUniqueIdentifier] domainIdentifier:[self.obj spotlightDomainIdentifier]
                                                                   attributeSet:[self.obj spotlightAttributes]];
    item.expirationDate = [self.params objectForKey:@"expirationDate"] ?: [NSDate distantFuture];
    [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:@[item] completionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"%s", __PRETTY_FUNCTION__);
            NSLog(@"%@", [error localizedDescription]);
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setState:OperationFinished];
        });
    }];
}

@end
