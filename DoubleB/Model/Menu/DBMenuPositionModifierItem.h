//
//  IHMenuProductModifierItem.h
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 18.11.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBMenuPositionModifier;

@interface DBMenuPositionModifierItem : NSObject

@property (strong, nonatomic) NSString *itemId;
@property (strong, nonatomic) NSString *itemName;
@property (nonatomic) double itemPrice;
@property (weak, nonatomic) DBMenuPositionModifier *modifier;
@property (strong, nonatomic) NSDictionary *itemDictionary;

+ (DBMenuPositionModifierItem *)itemFromDictionary:(NSDictionary *)itemDictionary
                                          modifier:(DBMenuPositionModifier *)modifier;

@end
