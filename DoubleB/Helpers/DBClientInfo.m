//
//  DBClientInfo.m
//  DoubleB
//
//  Created by Ощепков Иван on 18.02.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBClientInfo.h"
#import "NSString+AKNumericFormatter.h"

@interface DBClientInfo ()
@property (strong, nonatomic) NSUserDefaults *userDefaults;
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
    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    _clientName = [self.userDefaults objectForKey:kDBDefaultsName] ?: @"";
    _clientPhone = [self.userDefaults objectForKey:kDBDefaultsPhone] ?: @"";
    _clientMail = [self.userDefaults objectForKey:kDBDefaultsMail] ?: @"";
    
    return self;
}

- (BOOL)setClientName:(NSString *)clientName{
    _clientName = clientName;
    [self.userDefaults setObject:_clientName forKey:kDBDefaultsName];
    [self.userDefaults synchronize];
    
    return YES;
}

- (BOOL)setClientPhone:(NSString *)clientPhone{
    _clientPhone = clientPhone;
    [self.userDefaults setObject:_clientPhone forKey:kDBDefaultsPhone];
    [self.userDefaults synchronize];
    
    return YES;
}

- (BOOL)setClientMail:(NSString *)clientMail{
    _clientMail = clientMail;
    [self.userDefaults setObject:_clientMail forKey:kDBDefaultsMail];
    [self.userDefaults synchronize];
    
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

@end
