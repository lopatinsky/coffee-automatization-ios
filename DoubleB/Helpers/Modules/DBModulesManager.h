//
//  DBModulesManager.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 21/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DBModuleType) {
    DBModuleTypeMonthSubscription = 0,
    DBModuleTypeFriendGift = 1,
    DBModuleTypeFriendInvitation = 2
};

@interface DBModulesManager : NSObject

+ (instancetype)sharedInstance;

@end
