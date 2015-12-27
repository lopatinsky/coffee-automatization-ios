//
//  DBFriendGiftItemsModuleView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 19/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBModuleView.h"

typedef NS_ENUM(NSInteger, DBFGItemsModuleViewType) {
    DBFGItemsModuleViewTypeCommon,
    DBFGItemsModuleViewTypeSingleItem
};

@interface DBFGItemsModuleView : DBModuleView
@property (nonatomic) DBFGItemsModuleViewType *type;
@end
