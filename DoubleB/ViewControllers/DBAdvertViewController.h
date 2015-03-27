//
//  DBAdvertViewController.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 07.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBAdvertViewController;
@protocol DBAdvertViewControllerDelegate

@required
- (void)dbAdvertViewControllerUserDidClose:(DBAdvertViewController *)controller;
- (void)dbAdvertViewControllerUserDidConfirm:(DBAdvertViewController *)controller;

@end

@interface DBAdvertViewController : UIViewController

- (instancetype)initWithIcon:(NSString *)imageUrl htmlText:(NSString *)text;

@property (weak, nonatomic) id<DBAdvertViewControllerDelegate> delegate;

@end
