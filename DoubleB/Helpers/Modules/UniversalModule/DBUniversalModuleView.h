//
//  DBUniversalModuleView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 29/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBModuleView.h"

@class DBUniversalModule;

@interface DBUniversalModuleView : DBModuleView

@property (strong, nonatomic, readonly) DBUniversalModule *module;

- (instancetype)initWithModule:(DBUniversalModule *)module;

@end
