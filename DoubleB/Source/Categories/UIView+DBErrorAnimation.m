//
//  UIView+DBErrorAnimation.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 25.12.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "UIView+DBErrorAnimation.h"

@implementation UIView (DBErrorAnimation)

- (void)db_startObservingAnimationNotification{
    [self db_stopObservingAnimationNotification];
    
    __weak UIView *weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserver:weakSelf
                                             selector:@selector(observeNewOrderAllErrorElementsAnimationNotification:)
                                                 name:kDBNewOrderAnimateAllErrorElementsNotification object:nil];
}

- (void)db_stopObservingAnimationNotification{
    __weak UIView *weakSelf = self;
    [[NSNotificationCenter defaultCenter] removeObserver:weakSelf
                                                    name:kDBNewOrderAnimateAllErrorElementsNotification object:nil];
}

- (void)observeNewOrderAllErrorElementsAnimationNotification:(NSNotification *)notification{
    __weak UIView *weakSelf = self;
    void (^animationBlock)(UIView*) = notification.object;
    
    if(animationBlock){
        animationBlock(weakSelf);
    }
}

- (void)uiview_dealloc {
    // TODO: infinite loop?
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self uiview_dealloc];
}

@end
