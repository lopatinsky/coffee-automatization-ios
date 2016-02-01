//
//  DBMPInfoModuleView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 19/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBModuleView.h"

@interface DBMPInfoModuleView : DBModuleView
@property (strong, nonatomic) DBMenuPosition *position;

+ (DBMPInfoModuleView *)create;
@end
