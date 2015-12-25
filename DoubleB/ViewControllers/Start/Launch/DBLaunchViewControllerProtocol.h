//
//  DBLaunchViewControllerProtocol.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DBLaunchViewControllerProtocol <NSObject>
- (void)setExecutableBlock:(void (^)())executableBlock;
@end
