//
//  DBNOOddPopupView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 12/01/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBPopupComponent.h"

@interface DBPopupTextFieldView : DBPopupComponent
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *placeholder;
@property (nonatomic) UIKeyboardType keyboardType;

+ (DBPopupTextFieldView *)create;
- (void)showFrom:(UIView *)fromView onView:(UIView *)parentView;

@end
