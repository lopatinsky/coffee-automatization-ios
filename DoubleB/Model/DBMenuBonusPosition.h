//
//  DBMenuGift.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 21.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBMenuPosition.h"

@interface DBMenuBonusPosition : DBMenuPosition
@property (nonatomic) double pointsPrice;

- (instancetype)initWithResponseDictionary:(NSDictionary *)positionDictionary;
@end
