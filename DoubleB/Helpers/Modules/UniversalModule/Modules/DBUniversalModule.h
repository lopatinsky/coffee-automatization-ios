//
//  DBUniversalModule.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 29/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBUniversalModuleDelegate.h"

@class DBModuleView;

@interface DBUniversalModule : NSObject<NSCoding>

@property (strong, nonatomic) NSString *moduleId;

@property (strong, nonatomic, readonly) NSArray *items;
@property (strong, nonatomic) NSString *title;

@property (strong, nonatomic) NSString *jsonField;

@property (weak, nonatomic) id<DBUniversalModuleDelegate> delegate;

- (instancetype)initWithResponseDict:(NSDictionary *)dict;
- (void)syncWithResponseDict:(NSDictionary *)dict;

- (NSDictionary *)jsonRepresentation;

- (DBModuleView *)getModuleView;

@end
