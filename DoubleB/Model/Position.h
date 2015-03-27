//
//  Position.h
//  DoubleB
//
//  Created by Sergey Pronin on 7/31/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Position : NSObject

@property (nonatomic, strong) NSString *positionId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *descr;
@property (nonatomic, strong) NSString *pic;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSNumber *kal;
@property (nonatomic, strong) NSMutableArray *exts;

+ (instancetype)positionWithDictionary:(NSDictionary *)dictionary;
- (NSString *)extNameAtIndex:(NSInteger)index;

@end
