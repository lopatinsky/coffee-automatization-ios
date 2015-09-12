//
//  DBClientInfo.m
//  DoubleB
//
//  Created by Ощепков Иван on 18.02.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBClientInfo.h"

#import "NSString+AKNumericFormatter.h"

// External notification constants
NSString * const DBClientInfoNotificationClientName = @"DBClientInfoNotificationClientName";
NSString * const DBClientInfoNotificationClientPhone = @"DBClientInfoNotificationClientPhone";
NSString * const DBClientInfoNotificationClientMail = @"DBClientInfoNotificationClientMail";

// Internal storage constants
NSString *const kDBDefaultsName = @"kDBDefaultsName";
NSString *const kDBDefaultsPhone = @"kDBDefaultsPhone";
NSString *const kDBDefaultsMail = @"kDBDefaultsMail";

@interface DBClientInfo ()
@end

@implementation DBClientInfo

+ (instancetype)sharedInstance
{
    static DBClientInfo *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [DBClientInfo new];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    
    _clientName = [DBClientInfo valueForKey:kDBDefaultsName] ?: @"";
    _clientPhone = [DBClientInfo valueForKey:kDBDefaultsPhone] ?: @"";
    _clientMail = [DBClientInfo valueForKey:kDBDefaultsMail] ?: @"";
    
    return self;
}

- (BOOL)setClientName:(NSString *)clientName{
    _clientName = clientName;
    [DBClientInfo setValue:_clientName forKey:kDBDefaultsName];
    [self notifyObserverOf:DBClientInfoNotificationClientName];
    
    return YES;
}

- (BOOL)setClientPhone:(NSString *)clientPhone{
    _clientPhone = clientPhone;
    [DBClientInfo setValue:_clientPhone forKey:kDBDefaultsPhone];
    [self notifyObserverOf:DBClientInfoNotificationClientPhone];
    
    return YES;
}

- (BOOL)setClientMail:(NSString *)clientMail{
    _clientMail = clientMail;
    [DBClientInfo setValue:_clientMail forKey:kDBDefaultsMail];
    [self notifyObserverOf:DBClientInfoNotificationClientMail];
    
    return YES;
}

- (BOOL)validClientPhone{
    return [self validPhone:_clientPhone];
}

- (BOOL)validClientName{
    return [self validName:_clientName];
}

- (BOOL)validClientMail{
    return [self validMail:_clientMail];
}


- (BOOL)validPhone:(NSString *)phone{
    BOOL result = [self validPhoneCharacters:phone];
    result = phone.length > 0;
    
    NSString *onlyDecimal = [phone stringContainingOnlyDecimalDigits];
    result = result && onlyDecimal.length > 0;
    
    return result;
}

- (BOOL)validName:(NSString *)name{
    BOOL result = [self validNameCharacters:name];
    result = result && name.length > 0;
    
    NSString *withoutSpaces = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
    result = result && withoutSpaces.length > 0;
    
    return result;
}

- (BOOL)validMail:(NSString *)mail{
    return [self validMailCharacters:mail];
}

- (BOOL)validPhoneCharacters:(NSString *)phoneCharacters{
    NSCharacterSet *stringSet = [NSCharacterSet characterSetWithCharactersInString:phoneCharacters];
    NSMutableCharacterSet *charSet = [NSMutableCharacterSet decimalDigitCharacterSet];
    [charSet addCharactersInString:@"+() "];
    
    return [charSet isSupersetOfSet:stringSet];
}

- (BOOL)validNameCharacters:(NSString *)nameCharacters{
    NSCharacterSet *stringSet = [NSCharacterSet characterSetWithCharactersInString:nameCharacters];
    NSMutableCharacterSet *charSet = [NSMutableCharacterSet letterCharacterSet];
    [charSet addCharactersInString:@"- "];
    
    return [charSet isSupersetOfSet:stringSet];
}

- (BOOL)validMailCharacters:(NSString *)mailCharacters{
    return YES;
}

#pragma mark - DBPrimaryManager methods override

+ (NSString *)db_managerStorageKey {
    return @"DBDefaultsClientInfo";
}

@end
