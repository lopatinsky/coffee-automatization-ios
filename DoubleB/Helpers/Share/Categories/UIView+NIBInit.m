//
//  UIView+NIBInit.m
//  
//
//  Created by Balaban Alexander on 03/09/15.
//
//

#import "UIView+NIBInit.h"

@implementation UIView (NIBInit)

- (instancetype)initWithNibNamed:(NSString *)nibNameOrNil
{
    if (!nibNameOrNil) {
        nibNameOrNil = NSStringFromClass([self class]);
    }
    NSArray *viewsInNib = [[NSBundle mainBundle] loadNibNamed:nibNameOrNil
                                                        owner:self
                                                      options:nil];
    for (id view in viewsInNib) {
        if ([view isKindOfClass:[self class]]) {
            self = view;
            break;
        }
    }
    return [self initWithFrame:CGRectZero];
}

@end
