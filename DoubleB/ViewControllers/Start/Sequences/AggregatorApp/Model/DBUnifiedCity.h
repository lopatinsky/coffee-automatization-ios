//
//  DBCity.h
//  DoubleB
//
//  Created by Balaban Alexander on 25/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBUnifiedCity : NSObject

@property (strong, nonatomic) NSString *cityId;
@property (strong, nonatomic) NSString *cityName;

- (instancetype)initWithResponseDict:(NSDictionary *)response;

@end
