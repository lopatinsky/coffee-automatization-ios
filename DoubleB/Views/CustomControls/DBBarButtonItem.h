//
//  IHBarButtonItem.h
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 19.06.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBBarButtonItem : UIBarButtonItem
-(instancetype)initWithViewController:(UIViewController *)viewController action:(SEL)action;

@end
