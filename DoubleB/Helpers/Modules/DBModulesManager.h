//
//  DBModulesManager.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 21/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DBModuleType) {
    DBModuleTypeSubscription = 0,
    DBModuleTypeFriendGift = 1,
    DBModuleTypeFriendInvitation = 2,
    DBModuleTypeProfileScreenUniversal = 4,
    DBModuleTypeGeoPush = 5,
    DBModuleTypeFriendGiftMivako = 7,
	DBModuleTypePositionBalances = 10,
	DBModuleTypeOrderScreenUniversal = 11,
    DBModuleTypePersonsCount = 12,
    DBModuleTypeOddSum = 13,
    
    DBModuleTypeLast // Enum item for iteration, not in use
};

@interface DBModulesManager : NSObject

+ (instancetype)sharedInstance;

- (void)fetchModules:(void(^)(BOOL success))callback;
- (BOOL)moduleEnabled:(DBModuleType)type;

@end
