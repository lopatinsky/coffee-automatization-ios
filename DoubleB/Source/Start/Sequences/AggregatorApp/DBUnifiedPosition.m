//
//  DBUnifiedPosition.m
//  DoubleB
//
//  Created by Balaban Alexander on 25/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBUnifiedPosition.h"

@implementation DBUnifiedPosition

- (instancetype)initWithResponseDict:(NSDictionary *)response {
    if (self = [super init]) {
        NSMutableArray *positions = [NSMutableArray<DBMenuPosition *> new];
        self.venue = [[DBUnifiedVenue alloc] initWithDictionary:response[@"venue_info"] andCompanyDictionary:response[@"company"]];
        for (NSDictionary *item in response[@"items"]) {
            DBMenuPosition *position = [[DBMenuPosition alloc] initWithResponseDictionary:item];
            [positions addObject:position];
        }
        self.positions = [positions copy];
    }
    return self;
}

@end
