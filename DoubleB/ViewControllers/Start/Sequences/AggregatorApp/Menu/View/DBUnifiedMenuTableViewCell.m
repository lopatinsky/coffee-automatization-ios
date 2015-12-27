//
//  DBUnifiedMenuTableViewCell.m
//  DoubleB
//
//  Created by Balaban Alexander on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBUnifiedMenuTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "DBMenuPosition.h"

@interface DBUnifiedMenuTableViewCell()

@property (weak, nonatomic) IBOutlet UIView *gradientView;

@end

@implementation DBUnifiedMenuTableViewCell

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

- (void)setData:(NSDictionary *)info withType:(UnifiedTableViewType)type {
//    switch (type) {
//        case UnifiedMenu:
            self.nameLabel.text = info[@"title"];
            self.priceLabel.text = [NSString stringWithFormat:@"от %@%@", info[@"min_price"], [Compatibility currencySymbol]];
            self.infoLabel.text = [NSString stringWithFormat:@"в %@ заведениях",  @100];
            
            self.positionImageView.backgroundColor = [UIColor clearColor];
            self.positionImageView.opaque = NO;
            self.positionImageView.contentMode = UIViewContentModeScaleAspectFill;
            self.positionImageView.clipsToBounds = YES;
            if (![info[@"pic"] isKindOfClass:[NSNull class]]) {
                [self.positionImageView sd_setImageWithURL:[NSURL URLWithString:info[@"pic"]]];
            } else {
                [self.positionImageView sd_setImageWithURL:[NSURL URLWithString:@"http://coffeegid.ru/wp-content/uploads/2014/12/vanilnyj-kapuchino-recept.jpg"]];
            }
//            break;
//        case UnifiedPosition: {
//            DBMenuPosition *position = info[@"item"];
//            NSDictionary *venueInfo = info[@"venue_info"];
//            self.nameLabel.text = [position name];
//            self.priceLabel.text = [NSString stringWithFormat:@"%2.f%@", [position price], [Compatibility currencySymbol]];
//            self.infoLabel.text = venueInfo[@"title"];
//            
//            self.positionImageView.backgroundColor = [UIColor clearColor];
//            self.positionImageView.opaque = NO;
//            self.positionImageView.contentMode = UIViewContentModeScaleAspectFill;
//            self.positionImageView.clipsToBounds = YES;
//            if ([position imageUrl]) {
//                [self.positionImageView sd_setImageWithURL:[NSURL URLWithString:[position imageUrl]]];
//            } else {
//                [self.positionImageView sd_setImageWithURL:[NSURL URLWithString:@"http://express-f.ru/image/cache/data/Menu/kofe/good_4a83db8539f02-900x900.jpg"]];
//            }
//        }
//        default:
//            break;
//    }
}

@end
