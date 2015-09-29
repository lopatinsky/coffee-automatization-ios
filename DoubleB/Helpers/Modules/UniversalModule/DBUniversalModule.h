//
//  DBUniversalModule.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 29/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBUniversalModule : NSObject

@property (strong, nonatomic, readonly) NSArray *items;
@property (strong, nonatomic) NSString *title;

- (instancetype)initWithItems:(NSArray *)items;

- (NSDictionary *)jsonRepresentation;

@end
