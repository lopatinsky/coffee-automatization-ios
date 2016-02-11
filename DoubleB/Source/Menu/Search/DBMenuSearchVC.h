//
//  DBMenuSearchVC.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 10/02/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBMenuSearchVC;
@class DBMenuPosition;
@protocol DBMenuSearchVCDelegate <NSObject>

- (void)db_menuSearchVC:(DBMenuSearchVC*)controller didSelectPosition:(DBMenuPosition *)position;

@end

@interface DBMenuSearchVC : UIViewController
@property (weak, nonatomic) id<DBMenuSearchVCDelegate> delegate;
- (void)presentInContainer:(UIViewController *)container;
- (void)hide;
@end
