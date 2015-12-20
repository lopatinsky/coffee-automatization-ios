//
//  DBMPModifiersModuleView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 19/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBModuleView.h"

@interface DBMPModifiersModuleView : DBModuleView
@property (strong, nonatomic) DBMenuPosition *position;

+ (DBMPModifiersModuleView *)create;
@end
