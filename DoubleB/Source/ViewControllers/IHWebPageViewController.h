//
//  IHWebPageViewController.h
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 04.06.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IHWebPageViewController : UIViewController

@property (strong, nonatomic) NSString *sourceUrl;
@property (nonatomic, copy) void(^completionHandler)(BOOL success);
@property (strong, nonatomic) NSString *screenName;

@end
