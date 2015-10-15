//
//  DBClientInfo.h
//  DoubleB
//
//  Created by Ощепков Иван on 18.02.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBPrimaryManager.h"
#import "ManagerProtocol.h"
#import "DBUserProperty.h"

// External notification constants
extern NSString * const DBClientInfoNotificationClientName;
extern NSString * const DBClientInfoNotificationClientPhone;
extern NSString * const DBClientInfoNotificationClientMail;

@interface DBClientInfo : DBPrimaryManager<ManagerProtocol>
@property (strong, nonatomic, readonly) DBUserName *clientName;
@property (strong, nonatomic, readonly) DBUserPhone *clientPhone;
@property (strong, nonatomic, readonly) DBUserMail *clientMail;

+ (instancetype)sharedInstance;

// Return YES and replace current value if new value is valid
- (BOOL)setName:(NSString *)name;
- (BOOL)setPhone:(NSString *)phone;
- (BOOL)setMail:(NSString *)mail;

@end
