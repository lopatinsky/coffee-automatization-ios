//
//  DBProgressBackgroundView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 04/02/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBProgressBackgroundView : UIView

- (void)showOnViewWithBlur:(UIView *)parentView;
- (void)showOnView:(UIView *)parentView color:(UIColor *)color;

- (void)hide;

- (void)startAnimating;
- (void)stopAnimating;
- (void)showMessage:(NSString *)message;
@end
