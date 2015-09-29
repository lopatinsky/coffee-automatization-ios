//
//  DBUserProperty.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 19/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBUserProperty.h"

#import "NSString+AKNumericFormatter.h"

@implementation DBUserProperty

- (instancetype)init {
    self = [super init];
    
    self.value = @"";
    
    return self;
}

- (BOOL)valid {
    return [self valid:_value];
}

- (BOOL)valid:(NSString *)value {
    return [self validCharacters:value];
}

- (BOOL)validCharacters:(NSString *)characters {
    return YES;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [[[self class] alloc] init];
    if(self != nil){
        self.value = [aDecoder decodeObjectForKey:@"value"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_value forKey:@"value"];
}

@end

@implementation DBUserName

- (BOOL)valid:(NSString *)value {
    BOOL result = [super valid:value];
    result = result && value.length > 0;
    
    NSString *withoutSpaces = [value stringByReplacingOccurrencesOfString:@" " withString:@""];
    result = result && withoutSpaces.length > 0;
    
    return result;
}

- (BOOL)validCharacters:(NSString *)characters {
    NSCharacterSet *stringSet = [NSCharacterSet characterSetWithCharactersInString:characters];
    NSMutableCharacterSet *charSet = [NSMutableCharacterSet letterCharacterSet];
    [charSet addCharactersInString:@"- "];
    
    return [charSet isSupersetOfSet:stringSet];
}

@end

@implementation DBUserPhone

- (BOOL)valid:(NSString *)value {
    BOOL result = [super valid:value];
    result = result && value.length > 0;
    
    NSString *onlyDecimal = [value stringContainingOnlyDecimalDigits];
    result = result && onlyDecimal.length > 0;
    
    return result;
}

- (BOOL)validCharacters:(NSString *)characters {
    NSCharacterSet *stringSet = [NSCharacterSet characterSetWithCharactersInString:characters];
    NSMutableCharacterSet *charSet = [NSMutableCharacterSet decimalDigitCharacterSet];
    [charSet addCharactersInString:@"+()- "];
    
    return [charSet isSupersetOfSet:stringSet];
}

@end

@implementation DBUserMail

@end