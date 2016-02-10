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
#import "DBSearchBarButtonView.h"
#import "DBCustomBarButtonView.h"
#import "OrderCoordinator.h"

#import "UIControl+BlocksKit.h"

@interface DBBarButtonItem ()
@end

@implementation DBBarButtonItem

+ (DBBarButtonItem *)item:(DBBarButtonType)type handler:(void (^)())handler {
    DBBarButtonItemComponent *component = [DBBarButtonItemComponent create:type handler:handler];
    return [self itemWithComponents:@[component]];
}

+ (DBBarButtonItem *)itemWithComponents:(NSArray *)components {
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 35)];
    
    double offset = 0;
    for (DBBarButtonItemComponent *component in components) {
        UIView *view;
        double width = 35;
        
        switch (component.type) {
            case DBBarButtonTypeOrder:
                view = [DBOrderBarButtonView new];
                break;
            case DBBarButtonTypeProfile:
                view = [DBProfileBarButtonItem new];
                break;
            case DBBarButtonTypeSearch:{
                view = [DBSearchBarButtonView create];
                width = 25;
            }
                break;
            case DBBarButtonTypeCustom:
                view = [DBCustomBarButtonView new];
//                [(DBCustomBarButtonView *)view customTextLabel].text = params[@"text"];
//                buttonOrder.frame = CGRectMake(0, 0, 70, 35);
            default:
                break;
        }
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(offset, 0, width, 35);
        [button bk_addEventHandler:^(id sender) {
            if (component.handlerBlock)
                component.handlerBlock();
        } forControlEvents:UIControlEventTouchUpInside];
        
        view.userInteractionEnabled = NO;
        view.exclusiveTouch = NO;
        [button addSubview:view];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [view constrainHeight:[NSString stringWithFormat:@"%.0f", button.frame.size.height]];
        [view constrainWidth:[NSString stringWithFormat:@"%.0f", button.frame.size.width]];
        [view alignCenterWithView:button];
        
        offset += width;
        
        CGRect rect = customView.frame;
        rect.size.width = offset;
        customView.frame = rect;
        
        [customView addSubview:button];
    }
    
    DBBarButtonItem *item = [[DBBarButtonItem alloc] initWithCustomView:customView];
    return item;
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
            customView = [DBCustomBarButtonView new];
            [(DBCustomBarButtonView *)customView customTextLabel].text = params[@"text"];
            buttonOrder.frame = CGRectMake(0, 0, 70, 35);
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

@implementation DBBarButtonItemComponent

+ (DBBarButtonItemComponent *)create:(DBBarButtonType)type handler:(void (^)())handler {
    DBBarButtonItemComponent *compoment = [DBBarButtonItemComponent new];
    compoment.type = type;
    compoment.handlerBlock = handler;
    
    return compoment;
}

@end
