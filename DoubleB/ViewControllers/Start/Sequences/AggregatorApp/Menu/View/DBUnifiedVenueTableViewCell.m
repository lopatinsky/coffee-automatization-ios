//
//  DBUnifiedMenuTableViewCell.m
//  DoubleB
//
//  Created by Balaban Alexander on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBUnifiedVenueTableViewCell.h"
#import "DBMenuPosition.h"
#import "UIImageView+WebCache.h"

@interface DBUnifiedVenueTableViewCell()

@property (weak, nonatomic) IBOutlet UIView *gradientView;

@end

@implementation DBUnifiedVenueTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    CAGradientLayer *gradientLayer = [CAGradientLayer new];
    CGRect rect = self.gradientView.bounds;
    
    rect.size.width = [[UIScreen mainScreen] bounds].size.width;
    gradientLayer.frame = rect;
    gradientLayer.colors = @[(id)[UIColor colorWithWhite:0 alpha:0.7].CGColor, (id)[UIColor clearColor].CGColor];
    gradientLayer.startPoint = CGPointMake(0.5, 1.0);
    gradientLayer.endPoint = CGPointMake(0.5, 0.0);
    self.gradientView.backgroundColor = [UIColor blackColor];
    self.gradientView.layer.mask = gradientLayer;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setVenue:(Venue *)venue {
    self.nameLabel.text = venue.title;
    self.infoLabel.text = venue.address;
    self.priceLabel.text = venue.workingTime;
    
    self.positionImageView.backgroundColor = [UIColor clearColor];
    self.positionImageView.opaque = NO;
    self.positionImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.positionImageView.clipsToBounds = YES;
    
    [self.positionImageView sd_setImageWithURL:venue.venueDictionary[@"pic"] ?: @""];
}

@end
