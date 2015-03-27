//
//  DBClientInfo.h
//  DoubleB
//
//  Created by Ощепков Иван on 18.02.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBClientInfo : NSObject
@property (strong, nonatomic, readonly) NSString *clientName;
@property (strong, nonatomic, readonly) NSString *clientPhone;
@property (strong, nonatomic, readonly) NSString *clientMail;

+ (instancetype)sharedInstance;

// Return YES and replace current value if new value is valid
- (BOOL)setClientName:(NSString *)clientName;
- (BOOL)setClientPhone:(NSString *)clientPhone;
- (BOOL)setClientMail:(NSString *)clientMail;

- (BOOL)validPhone;
- (BOOL)validName;
- (BOOL)validMail;

- (BOOL)validPhoneCharacters:(NSString *)phoneCharacters;
- (BOOL)validNameCharacters:(NSString *)nameCharacters;
- (BOOL)validMailCharacters:(NSString *)mailCharacters;
@end
