//
//  DBUniversalModuleTextItemView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 29/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBModuleView.h"

@class DBUniversalModuleItem;

@interface DBUniversalModuleTextItemView : DBModuleView

@property (strong, nonatomic, readonly) DBUniversalModuleItem *item;

- (instancetype)initWithItem:(DBUniversalModuleItem *)item;

@end
