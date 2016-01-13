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
    DBUniversalModuleItemTypeInteger
};

@interface DBUniversalModuleItem : NSObject<NSCoding>


@property (nonatomic, readonly) DBUniversalModuleItemType type;
@property (strong, nonatomic) NSString *itemId;
@property (strong, nonatomic) NSString *placeholder;
@property (strong, nonatomic) NSString *text;

@property (nonatomic) NSInteger order;

@property (strong, nonatomic) NSString *jsonField;

@property (strong, nonatomic) NSArray *restrictions;
@property (nonatomic, readonly) BOOL availableAccordingRestrictions;

@property (weak, nonatomic) id<DBUniversalModuleDelegate> delegate;

- (instancetype)initWithResponseDict:(NSDictionary *)dict;
- (void)syncWithResponseDict:(NSDictionary *)dict;

- (void)save;

@end
