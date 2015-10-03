//
//  IHProductTableViewCell.m
//  IIko Hackathon
//
//  Created by Balaban Alexander on 04/04/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBPositionCell.h"
#import "DBMenuPosition.h"
#import "DBTableItemInactivityView.h"

#import "UIView+RoundedCorners.h"
#import "UIImageView+WebCache.h"

@interface DBPositionCell()
@property (strong, nonatomic) DBTableItemInactivityView *inactivityView;
@end

@implementation DBPositionCell
@synthesize position = _position;

- (instancetype)initWithType:(DBPositionCellAppearanceType)type{
    NSString *nibIdentifier = [DBPositionCell reuseIdentifierFor:type];
    
    self = [[[NSBundle mainBundle] loadNibNamed:nibIdentifier owner:self options:nil] firstObject];
    _appearanceType = type;
    
    return self;
}

+ (NSString *)reuseIdentifierFor:(DBPositionCellAppearanceType)type {
    if (type == DBPositionCellAppearanceTypeCompact) {
        return @"DBPositionCompactCell";
    } else {
        return @"DBPositionCell";
    }
}

- (void)awakeFromNib
{
    self.positionImageView = [self viewWithTag:1];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor whiteColor];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.orderButton addTarget:self action:@selector(orderButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.priceLabel.backgroundColor = [UIColor db_defaultColor];
    [self.priceLabel setRoundedCorners];
    self.priceLabel.textColor = [UIColor whiteColor];
    
    self.separatorView.backgroundColor = [UIColor db_separatorColor];
    
    if(_appearanceType == DBPositionCellAppearanceTypeFull){
        [self.positionImageView db_showDefaultImage];
    }
    
    self.inactivityView = [DBTableItemInactivityView new];
}

- (void)configureWithPosition:(DBMenuPosition *)position{
    _position = position;
    
    self.titleLabel.text = position.name;
    [self reloadPriceLabel];
    
    if(_appearanceType == DBPositionCellAppearanceTypeFull){
        self.descriptionLabel.text = position.positionDescription;
        if(position.weight == 0){
            self.weightLabel.hidden = YES;
        } else {
            self.weightLabel.text = [NSString stringWithFormat:@"%.0f %@", position.weight, NSLocalizedString(@"г", nil)];
            self.weightLabel.hidden = NO;
        }
        
        self.positionImageView.contentMode = [ViewManager defaultMenuPositionIconsContentMode];
        [self.positionImageView db_showDefaultImage];
        [self.positionImageView sd_setImageWithURL:[NSURL URLWithString:position.imageUrl]
                                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                if(!error){
                                                    [self.positionImageView db_hideDefaultImage];
                                                }
                                            }];
    }
}


- (void)reloadPriceLabel{
    if(self.contentType == DBPositionCellContentTypeBonus){
        self.priceLabel.text = [NSString stringWithFormat:@"%.0f", self.position.price];
    } else {
        self.priceLabel.text = [NSString stringWithFormat:@"%.0f %@", self.position.price, [Compatibility currencySymbol]];
        
//        if(self.position.price < self.position.actualPrice){
//            self.priceLabel.text = [NSString stringWithFormat:@"%@ %.0f %@", NSLocalizedString(@"от", nil), self.position.price, [Compatibility currencySymbol]];
//        }
    }
}

- (IBAction)orderButtonPressed:(id)sender {
    [self.delegate positionCellDidOrder:self];
}

- (void)animatePositionAdditionWithCompletion:(void(^)())completion{
    UIView *view = [[UIView alloc] initWithFrame:self.orderButton.frame];
    view.layer.cornerRadius = view.frame.size.height / 2.f;
    view.layer.masksToBounds = YES;
    view.backgroundColor = [UIColor db_defaultColor];
    
    [self.contentView addSubview:view];
    
    self.orderButton.alpha = 0;
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         view.transform = CGAffineTransformMakeScale(1.5, 1.5);
                     }
                     completion:^(BOOL finished) {
                         [view removeFromSuperview];
                         
                         if(completion)
                             completion();
                     }];
    
    [UIView animateWithDuration:0.2
                          delay:0.1
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         view.alpha = 0;
                         self.orderButton.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         [view removeFromSuperview];
                     }];
}

- (void)disable{
    self.inactivityView.frame = self.contentView.bounds;
    [self.inactivityView setErrors:nil];
    
    [self.contentView addSubview:self.inactivityView];
    [self setUserInteractionEnabled:NO];
}

- (void)enable{
    [self.inactivityView removeFromSuperview];
    [self setUserInteractionEnabled:YES];
}

#pragma mark - PositionCellProtocol
- (DBMenuPosition *)position {
    return _position;
}

@end
