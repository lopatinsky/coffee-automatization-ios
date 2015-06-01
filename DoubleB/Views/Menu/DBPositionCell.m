//
//  IHProductTableViewCell.m
//  IIko Hackathon
//
//  Created by Balaban Alexander on 04/04/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBPositionCell.h"
#import "DBMenuPosition.h"
#import "DBMenuBonusPosition.h"
#import "Compatibility.h"
#import "DBTableItemInactivityView.h"

#import "UIView+RoundedCorners.h"
#import "UIImageView+WebCache.h"

@interface DBPositionCell()
@property (strong, nonatomic) DBTableItemInactivityView *inactivityView;
@end

@implementation DBPositionCell

- (instancetype)initWithType:(DBPositionCellAppearanceType)type{
    NSString *nibIdentifier;
    if (type == DBPositionCellAppearanceTypeCompact) {
        nibIdentifier = @"DBPositionCompactCell";
    } else {
        nibIdentifier = @"DBPositionCell";
    }
    
    self = [[[NSBundle mainBundle] loadNibNamed:nibIdentifier owner:self options:nil] firstObject];
    _appearanceType = type;
    
    return self;
}

- (void)awakeFromNib
{
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
            self.weightLabel.text = [NSString stringWithFormat:@"%.0f %@", position.weight, NSLocalizedString(@"г.", nil)];
            self.weightLabel.hidden = NO;
        }
        
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
    if([self.position isKindOfClass:[DBMenuBonusPosition class]]){
        self.priceLabel.text = [NSString stringWithFormat:@"%.0f", ((DBMenuBonusPosition *)self.position).pointsPrice];
    } else {
        self.priceLabel.text = [NSString stringWithFormat:@"%.0f %@", self.position.actualPrice, [Compatibility currencySymbol]];
    }
}

- (IBAction)orderButtonPressed:(id)sender {
    [self animateAdditionWithCompletion:^{
        [self.delegate positionCellDidOrder:self];
    }];
}

- (void)animateAdditionWithCompletion:(void(^)())completion{
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
}

- (void)enable{
    [self.inactivityView removeFromSuperview];
}

@end
