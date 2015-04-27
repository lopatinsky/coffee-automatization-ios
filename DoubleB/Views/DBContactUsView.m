//
//  DBCallUsView.m
//  DoubleB
//
//  Created by Dmitriy Stupivtsev on 21.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBContactUsView.h"

#import <QuartzCore/QuartzCore.h>

@interface DBContactUsView()
@property (weak, nonatomic) IBOutlet UIView *smallBackgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *callUsLabel;
@end

@implementation DBContactUsView

- (instancetype)init{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBContactUsView" owner:self options:nil] firstObject];
    self.backgroundColor = [UIColor db_defaultColor];
    
    return self;
}

- (void)awakeFromNib{
    self.layer.cornerRadius = 18.f;
    self.layer.masksToBounds = YES;
}

- (void)smallBackgroundColourDefault {
    const CGFloat *initialColor = CGColorGetComponents([self.backgroundColor CGColor]);
    float newRed = initialColor[0] * 0.7f;
    float newGreen = initialColor[1] * 0.7f;
    float newBlue = initialColor[2] * 0.7f;
    self.smallBackgroundView.backgroundColor = [UIColor colorWithRed:newRed green:newGreen blue:newBlue alpha:1.f];
}

- (void)setIconImage:(UIImage *)image {
    self.iconImageView.image = image;
}

- (void)setText:(NSString *)text {
    self.callUsLabel.text = text;
}

@end
