//
//  DBUnifiedAppManager.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBPrimaryManager.h"

#import <CoreLocation/CoreLocation.h>

@interface DBUnifiedAppManager : DBPrimaryManager

- (NSArray *)venues;
- (NSArray *)menu;
- (NSArray *)allPositions;
- (NSArray *)positionsForItem:(NSNumber *)stringId;

- (void)fetchMenu:(void(^)(BOOL success))callback;
- (void)fetchVenues:(void (^)(BOOL success))callback;
- (void)fetchPositionsWithId:(NSString *)itemId withCallback:(void (^)(BOOL))callback;

@end
