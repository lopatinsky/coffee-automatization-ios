//
//  UIView+DBErrorAnimation.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 25.12.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (DBErrorAnimation)

- (void)db_startObservingAnimationNotification;
- (void)db_stopObservingAnimationNotification;

- (void)uiview_dealloc;

@end
