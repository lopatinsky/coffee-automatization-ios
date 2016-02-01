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
    
    // Migrate data if it was saved in old format
    [self migrateData];
    
    _clientName = [NSKeyedUnarchiver unarchiveObjectWithData:[DBClientInfo valueForKey:kDBDefaultsName]] ?: [DBUserName new];
    _clientPhone = [NSKeyedUnarchiver unarchiveObjectWithData:[DBClientInfo valueForKey:kDBDefaultsPhone]] ?: [DBUserPhone new];
    _clientMail = [NSKeyedUnarchiver unarchiveObjectWithData:[DBClientInfo valueForKey:kDBDefaultsMail]] ?: [DBUserMail new];
    
    return self;
}

- (BOOL)setName:(NSString *)name {
    _clientName.value = name;
    
    NSData *nameData = [NSKeyedArchiver archivedDataWithRootObject:_clientName];
    [DBClientInfo setValue:nameData forKey:kDBDefaultsName];
    [self notifyObserverOf:DBClientInfoNotificationClientName];
    
    return YES;
}

- (BOOL)setPhone:(NSString *)phone {
    _clientPhone.value = phone;
    
    NSData *phoneData = [NSKeyedArchiver archivedDataWithRootObject:_clientPhone];
    [DBClientInfo setValue:phoneData forKey:kDBDefaultsPhone];
    [self notifyObserverOf:DBClientInfoNotificationClientPhone];
    
    return YES;
}

- (BOOL)setMail:(NSString *)mail {
    _clientMail.value = mail;
    
    NSData *mailData = [NSKeyedArchiver archivedDataWithRootObject:_clientMail];
    [DBClientInfo setValue:mailData forKey:kDBDefaultsMail];
    [self notifyObserverOf:DBClientInfoNotificationClientMail];
    
    return YES;
}

// Migrate data if it was saved in old format
- (void)migrateData {
    if([[DBClientInfo valueForKey:kDBDefaultsName] isKindOfClass:[NSString class]]) {
        _clientName = [DBUserName new];
        [self setName:[DBClientInfo valueForKey:kDBDefaultsName]];
    }
    
    if([[DBClientInfo valueForKey:kDBDefaultsPhone] isKindOfClass:[NSString class]]) {
        _clientPhone = [DBUserPhone new];
        
        NSString *phone = [DBClientInfo valueForKey:kDBDefaultsPhone];
        NSMutableCharacterSet *nonDigitsSet = [NSMutableCharacterSet decimalDigitCharacterSet];
        [nonDigitsSet invert];
        
        NSString *validText = [[phone componentsSeparatedByCharactersInSet:nonDigitsSet] componentsJoinedByString:@""];
        [self setPhone:validText];
    }
    
    if([[DBClientInfo valueForKey:kDBDefaultsMail] isKindOfClass:[NSString class]]) {
        _clientMail = [DBUserMail new];
        [self setMail:[DBClientInfo valueForKey:kDBDefaultsMail]];
    }
}

#pragma mark - DBPrimaryManager methods override

+ (NSString *)db_managerStorageKey {
    return @"DBDefaultsClientInfo";
}

#pragma mark - ManagerProtocol

- (void)flushCache {
    
}

- (void)flushStoredCache {
    [self flushCache];
    
    [DBClientInfo removeAllValues];
}

@end
