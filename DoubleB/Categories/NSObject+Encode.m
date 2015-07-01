//
//  NSObject+Encode.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 17.06.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "NSObject+Encode.h"

@implementation NSObject (Encode)

- (NSString *)encodedString{
    if([self isKindOfClass:[NSArray class]] || [self isKindOfClass:[NSDictionary class]]){
        NSData *data = [NSJSONSerialization dataWithJSONObject:self
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    } else {
        return @"";
    }
}

@end
