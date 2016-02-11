//
//  DBSearchManager.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 11/02/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBPrimaryManager.h"

@interface DBSearchManager : DBPrimaryManager

- (NSString *)searchText;
- (NSArray *)filterPositions:(NSString *)text;

@end
