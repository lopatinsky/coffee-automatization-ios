//
//  DBCustomItem.m
//  DoubleB
//
//  Created by Balaban Alexander on 18/01/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBCustomItem.h"

@implementation DBCustomItem

- (instancetype)initWithTitle:(NSString *)title andURLString:(NSString *)urlString {
    if (self = [super init]) {
        self.title = title;
        self.urlString = urlString;
    }
    return self;
}

#pragma mark - NSCoding methods

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [DBCustomItem new];
    if (self) {
        self.title = [aDecoder decodeObjectForKey:@"__itemTitle"];
        self.urlString = [aDecoder decodeObjectForKey:@"__urlString"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.title forKey:@"__itemTitle"];
    [aCoder encodeObject:self.urlString forKey:@"__urlString"];
}

@end
