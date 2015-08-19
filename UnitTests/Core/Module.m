//
//  Module.m
//  
//
//  Created by Balaban Alexander on 19/08/15.
//
//

#import "Module.h"

@interface Module()

@property (nonatomic, strong) NSDictionary *orderDict;
@property (nonatomic, strong) NSDictionary *checkOrderDict;

@end

@implementation Module

- (instancetype)initWithOrderDict:(NSDictionary *)orderDict andCheckOrderDict:(NSDictionary *)checkOrderDict {
    if (self = [super init]) {
        self.orderDict = orderDict;
        self.checkOrderDict = checkOrderDict;
    }
    return self;
}

- (NSDictionary *)getOrderParams {
    return self.orderDict;
}

- (NSDictionary *)getCheckOrderParams {
    return self.checkOrderDict;
}

@end
