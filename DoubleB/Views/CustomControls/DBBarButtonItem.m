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
#import "DBCustomBarButtonView.h"
#import "OrderCoordinator.h"

typedef NS_ENUM(NSInteger, DBBarButtonType) {
    DBBarButtonTypeOrder = 0,
    DBBarButtonTypeProfile,
    DBBarButtonTypeCustom = 100
};

@interface DBBarButtonItem ()
@end

@implementation DBBarButtonItem

+ (DBBarButtonItem *)orderItem:(UIViewController *)controller action:(SEL)action {
    return [self itemWithType:DBBarButtonTypeOrder controller:controller params:nil action:action];
}

+ (DBBarButtonItem *)profileItem:(UIViewController *)controller action:(SEL)action {
    return [self itemWithType:DBBarButtonTypeProfile controller:controller params:nil action:action];
}

+ (DBBarButtonItem *)customItem:(UIViewController *)controller withText:(NSString *)text action:(SEL)action {
    return [self itemWithType:DBBarButtonTypeCustom controller:controller params:@{@"text": text} action:action];
}

+ (DBBarButtonItem *)itemWithType:(DBBarButtonType)type
                       controller:(UIViewController *)controller
                           params:(NSDictionary *)params
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
            break;
        case DBBarButtonTypeCustom:
            customView = [[DBCustomBarButtonView alloc] initWithText:params[@"text"]];
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
