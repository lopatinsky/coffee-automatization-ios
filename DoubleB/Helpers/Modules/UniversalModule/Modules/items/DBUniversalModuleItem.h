//
//  DBUniversalModuleItem.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 29/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBUniversalModuleDelegate.h"

@interface DBUniversalModuleItem : NSObject<NSCoding>

@property (strong, nonatomic) NSString *itemId;
@property (strong, nonatomic) NSString *placeholder;
@property (strong, nonatomic) NSString *text;

@property (nonatomic) NSInteger order;

@property (strong, nonatomic) NSString *jsonField;

@property (weak, nonatomic) id<DBUniversalModuleDelegate> delegate;

- (instancetype)initWithResponseDict:(NSDictionary *)dict;
- (void)syncWithResponseDict:(NSDictionary *)dict;

- (void)save;

@end
