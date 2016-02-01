//
//  DBUserProperty.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 19/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBUserProperty : NSObject<NSCoding>

@property (strong, nonatomic) NSString *value;
@property (nonatomic) BOOL valid;

- (BOOL)valid:(NSString *)value;
- (BOOL)validCharacters:(NSString *)characters;

@end

@interface DBUserName : DBUserProperty
@end

@interface DBUserPhone : DBUserProperty
@end

@interface DBUserMail : DBUserProperty
@end