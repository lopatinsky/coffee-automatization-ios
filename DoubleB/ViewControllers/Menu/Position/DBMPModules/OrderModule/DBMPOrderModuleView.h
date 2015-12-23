//
//  DBMPOrderModuleView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 21/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBModuleView.h"

@interface DBMPOrderModuleView : DBModuleView
+ (DBMPOrderModuleView *)create;

@property (strong, nonatomic) DBMenuPosition *position;
@end
