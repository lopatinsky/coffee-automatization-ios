//
//  IHBarButtonItem.h
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 19.06.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DBBarButtonType) {
    DBBarButtonTypeOrder = 0,
    DBBarButtonTypeProfile,
    DBBarButtonTypeSearch,
    DBBarButtonTypeCustom
};

@interface DBBarButtonItem : UIBarButtonItem

+ (DBBarButtonItem *)itemWithComponents:(NSArray *)components;
+ (DBBarButtonItem *)item:(DBBarButtonType)type handler:(void (^)())handler;

+ (DBBarButtonItem *)customItem:(UIViewController *)controller withText:(NSString *)text action:(SEL)action;

@end

@interface DBBarButtonItemComponent : NSObject
@property (copy, nonatomic) void (^handlerBlock)();
@property (nonatomic) DBBarButtonType type;

+ (DBBarButtonItemComponent *)create:(DBBarButtonType)type handler:(void (^)())handler;
@end
