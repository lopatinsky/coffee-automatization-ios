//
//  DBUniversalModule.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 29/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBModuleView;

@interface DBUniversalModule : NSObject

@property (strong, nonatomic, readonly) NSArray *items;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *jsonField;

- (instancetype)initWithItems:(NSArray *)items;

- (NSDictionary *)jsonRepresentation;

- (DBModuleView *)getModuleView;

@end
