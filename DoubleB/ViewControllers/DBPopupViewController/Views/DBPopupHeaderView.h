//
//  DBPopupHeaderView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 16/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBPopupHeaderView : UIView
@property (nonatomic, copy) void(^doneBlock)();

+ (DBPopupHeaderView *)create;
@end
