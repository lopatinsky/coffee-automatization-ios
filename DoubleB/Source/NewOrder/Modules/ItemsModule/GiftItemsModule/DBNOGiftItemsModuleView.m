//
//  DBNOGiftItemsModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 15/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBNOGiftItemsModuleView.h"
#import "OrderCoordinator.h"

@implementation DBNOGiftItemsModuleView

- (instancetype)init {
    self = [super init];
    
    [[OrderCoordinator sharedInstance] addObserver:self withKeyPath:CoordinatorNotificationPromoUpdated selector:@selector(reload)];
    
    return self;
}

- (void)dealloc {
    [[OrderCoordinator sharedInstance] removeObserver:self];
}

- (ItemsManager *)manager {
    return [OrderCoordinator sharedInstance].orderGiftsManager;
}


@end
