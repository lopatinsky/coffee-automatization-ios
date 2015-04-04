//
//  UIViewController+Animation.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 03.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "UIViewController+DBAnimation.h"

@implementation UIViewController (DBAnimation)

- (void)animateAddProductCircle:(CGFloat)rad
                       fromRect:(CGRect)startFrame fromView:(UIView *)startView
                         toRect:(CGRect)endFrame toView:(UIView *)endView
                     completion:(void (^)())completion{
    CGRect startRect = [startView convertRect:startFrame toView:self.view];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(startRect.origin.x + startRect.size.width / 2 - rad, startRect.origin.y + startRect.size.height / 2 - rad, rad * 2, rad * 2)];
    view.layer.cornerRadius = rad;
    view.backgroundColor = [UIColor db_defaultColor];
    
    [self.view addSubview:view];
    
    
    CGRect endRect = [endView convertRect:endFrame toView:self.view];
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         CGRect frame = view.frame;
                         frame.origin.y = endRect.origin.y + endRect.size.height / 2 - rad;
                         view.frame = frame;
                     }
                     completion:^(BOOL finished) {
                         [view removeFromSuperview];
                     }];
    
    [UIView animateWithDuration:0.2
                          delay:0.1
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         view.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [view removeFromSuperview];
                     }];
    
    if(completion)
        completion();
}

@end
