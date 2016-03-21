//
//  DBUniversalModuleItem.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 29/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBUniversalModuleDelegate.h"

typedef NS_ENUM(NSInteger, DBUniversalModuleItemType) {
    DBUniversalModuleItemTypeString = 0,
    DBUniversalModuleItemTypeInteger = 1,
    DBUniversalModuleItemTypeDate = 3,
    DBUniversalModuleItemTypeItems = 4
};

@interface DBUniversalModuleItem : NSObject<NSCoding>
@property (nonatomic, readonly) DBUniversalModuleItemType type;
@property (strong, nonatomic) NSString *itemId;
@property (strong, nonatomic) NSString *placeholder;

@property (nonatomic) NSInteger order;

@property (strong, nonatomic) NSString *jsonField;

@property (strong, nonatomic) NSArray *restrictions;
@property (nonatomic, readonly) BOOL availableAccordingRestrictions;

@property (weak, nonatomic) id<DBUniversalModuleDelegate> delegate;

- (instancetype)initWithResponseDict:(NSDictionary *)dict;
- (void)syncWithResponseDict:(NSDictionary *)dict;

- (NSDictionary *)jsonRepresentation;

- (void)save;

// String and Integer type
@property (strong, nonatomic) NSString *text;

// Date type
@property (strong, nonatomic) NSDate *selectedDate;
@property (strong, nonatomic) NSDate *minDate;
@property (strong, nonatomic) NSDate *maxDate;

// Items type
@property (strong, nonatomic) NSString *selectedItem;
@property (strong, nonatomic) NSArray *items;
@property (nonatomic) NSInteger defaultItem;

@end
