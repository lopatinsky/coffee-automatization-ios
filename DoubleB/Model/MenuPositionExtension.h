//
//  Grain.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 09.12.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MenuPositionExtension : NSObject

@property (strong, nonatomic) NSString *extId;
@property (strong, nonatomic) NSString *extName;
@property (strong, nonatomic) NSNumber *extPrice;

+ (instancetype)extensionWithName:(NSString *)name id:(NSString *)extensionId price:(NSNumber *)extensionPrice;

@end
