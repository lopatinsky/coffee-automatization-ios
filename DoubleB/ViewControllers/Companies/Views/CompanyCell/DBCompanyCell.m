//
//  DBCompanyCell.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 03/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBCompanyCell.h"
#import "DBCompaniesManager.h"

#import "UIImageView+WebCache.h"

@interface DBCompanyCell()
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIView *gradientView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation DBCompanyCell

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBCompanyCell" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    CGRect rect = self.gradientView.bounds;
    rect.size.width = [UIScreen mainScreen].bounds.size.width;
    gradientLayer.frame = rect;
    gradientLayer.colors = @[(id)[UIColor colorWithWhite:0 alpha:0.5].CGColor, (id)[UIColor clearColor].CGColor];
    gradientLayer.startPoint = CGPointMake(0.5, 1.0);
    gradientLayer.endPoint = CGPointMake(0.5, 0.0);
    self.gradientView.layer.mask = gradientLayer;
}

- (void)configure:(DBCompany *)company {
    [self.photoImageView sd_setImageWithURL:[NSURL URLWithString:company.companyImageUrl]
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     }];
    
    self.titleLabel.text = company.companyName;
}

@end
