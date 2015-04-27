//
//  DBCallUsView.h
//  DoubleB
//
//  Created by Dmitriy Stupivtsev on 21.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBContactUsView : UIView
- (instancetype)init;
- (void)smallBackgroundColourDefault;
- (void)setIconImage:(UIImage *)iconImage;
- (void)setText:(NSString *)text;
@end
