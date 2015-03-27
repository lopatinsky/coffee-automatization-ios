//
//  Menu.h
//  DoubleB
//
//  Created by Dmitriy Stupivtsev on 06.02.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Position.h"

@interface DBMenuCategory : NSObject
@property (nonatomic) id categoryId;
@property (nonatomic, strong) NSString *categoryName;
@property (nonatomic, strong) NSArray *items;

+ (instancetype) category:(id)categoryId name:(NSString *)categoryName items:(NSArray *)items;
@end