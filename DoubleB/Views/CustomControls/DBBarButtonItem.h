//
//  IHBarButtonItem.h
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 19.06.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBBarButtonItem : UIBarButtonItem

+ (DBBarButtonItem *)orderItem:(UIViewController *)controller action:(SEL)action;
+ (DBBarButtonItem *)profileItem:(UIViewController *)controller action:(SEL)action;
+ (DBBarButtonItem *)customItem:(UIViewController *)controller withText:(NSString *)text action:(SEL)action;

@end
