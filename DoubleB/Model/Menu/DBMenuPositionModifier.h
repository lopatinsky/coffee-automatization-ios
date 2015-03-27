//
//  IHMenuProductModifier.h
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 18.11.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBMenuPositionModifierItem;

typedef NS_ENUM(NSInteger, ModifierType) {
    ModifierTypeGroup = 0,
    ModifierTypeSingle = 1
};

@interface DBMenuPositionModifier : NSObject

@property (nonatomic, readonly) ModifierType modifierType;
@property (strong, nonatomic, readonly) NSString *modifierId;
@property (strong, nonatomic, readonly) NSString *modifierName;
@property (strong, nonatomic, readonly) NSDictionary *modifierDictionary;

// Only for Single modifier
@property (nonatomic, readonly) double modifierPrice;
@property (nonatomic, readonly) NSInteger maxAmount;
@property (nonatomic, readonly) NSInteger minAmount;

//Only for Group modifiers
@property (strong, nonatomic, readonly) NSMutableArray *items;
@property (strong, nonatomic) DBMenuPositionModifierItem *lastSelectedItem;

+ (DBMenuPositionModifier *)groupModifierFromDictionary:(NSDictionary *)modifierDictionary;
- (BOOL)synchronizeGroupModifierWithDictionary:(NSDictionary *)modifierDictionary;


+ (DBMenuPositionModifier *)singleModifierFromDictionary:(NSDictionary *)modifierDictionary;

@end
