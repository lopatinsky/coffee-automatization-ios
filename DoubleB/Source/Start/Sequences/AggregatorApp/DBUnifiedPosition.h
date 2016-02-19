//
//  DBUnifiedPosition.h
//  DoubleB
//
//  Created by Balaban Alexander on 25/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DBUnifiedVenue.h"
#import "DBMenuPosition.h"

@interface DBUnifiedPosition : NSObject

@property (nonatomic, strong) DBUnifiedVenue *venue;
@property (nonatomic, strong) NSArray<DBMenuPosition *> *positions;

- (instancetype)initWithResponseDict:(NSDictionary *)response;

@end
