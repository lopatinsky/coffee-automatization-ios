//
//  IHBarButtonItem.m
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 19.06.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBBarButtonItem.h"
#import "DBOrderBarButtonView.h"
#import "DBProfileBarButtonItem.h"
#import "OrderCoordinator.h"

typedef NS_ENUM(NSInteger, DBBarButtonType) {
    DBBarButtonTypeOrder = 0,
    DBBarButtonTypeProfile
};

@interface DBBarButtonItem ()
@end

@implementation DBBarButtonItem

+ (DBBarButtonItem *)orderItem:(UIViewController *)controller action:(SEL)action {
    return [self itemWithType:DBBarButtonTypeOrder controller:controller action:action];
}

+ (DBBarButtonItem *)profileItem:(UIViewController *)controller action:(SEL)action {
    return [self itemWithType:DBBarButtonTypeProfile controller:controller action:action];
}

+ (DBBarButtonItem *)itemWithType:(DBBarButtonType)type
                       controller:(UIViewController *)controller
                           action:(SEL)action {
    UIButton *buttonOrder = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonOrder.frame = CGRectMake(0, 0, 35, 35);
    [buttonOrder addTarget:controller action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIView *customView;
    switch (type) {
        case DBBarButtonTypeOrder:
            customView = [DBOrderBarButtonView new];
            break;
        case DBBarButtonTypeProfile:
            customView = [DBProfileBarButtonItem new];
            
        default:
            break;
    }
    
    customView.userInteractionEnabled = NO;
    customView.exclusiveTouch = NO;
    [buttonOrder addSubview:customView];
    customView.translatesAutoresizingMaskIntoConstraints = NO;
    [customView alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:buttonOrder];
    
    DBBarButtonItem *item = [[DBBarButtonItem alloc] initWithCustomView:buttonOrder];
    return item;
}

@end
