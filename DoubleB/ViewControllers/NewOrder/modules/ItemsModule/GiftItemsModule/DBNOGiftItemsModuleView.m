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
    
}

- (ItemsManager *)manager {
    return [OrderCoordinator sharedInstance].orderGiftsManager;
}


@end
