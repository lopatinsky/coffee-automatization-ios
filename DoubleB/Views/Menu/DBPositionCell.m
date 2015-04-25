//
//  IHProductTableViewCell.m
//  IIko Hackathon
//
//  Created by Balaban Alexander on 04/04/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBPositionCell.h"
#import "DBMenuPosition.h"
#import "Compatibility.h"

#import "UIImageView+WebCache.h"

@interface DBPositionCell()

@end

@implementation DBPositionCell

- (instancetype)initWithType:(DBPositionCellType)type{
    NSString *nibIdentifier;
    if (type == DBPositionCellTypeCompact) {
        nibIdentifier = @"DBPositionCompactCell";
    } else {
        nibIdentifier = @"DBPositionCell";
    }
    
    self = [[[NSBundle mainBundle] loadNibNamed:nibIdentifier owner:self options:nil] firstObject];
    _type = type;
    
    return self;
}

- (void)awakeFromNib
{
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor whiteColor];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.orderButton addTarget:self action:@selector(orderButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.priceLabel.backgroundColor = [UIColor db_defaultColor];
    self.priceLabel.layer.cornerRadius = self.priceLabel.frame.size.height / 2;
    self.priceLabel.layer.masksToBounds = YES;
    self.priceLabel.textColor = [UIColor whiteColor];
    
    self.separatorView.backgroundColor = [UIColor db_separatorColor];
    
    if(self.type == DBPositionCellTypeFull){
        [self.positionImageView db_showDefaultImage];
    }
}

- (void)configureWithPosition:(DBMenuPosition *)position{
    _position = position;
    
    self.titleLabel.text = position.name;
    self.priceLabel.text = [NSString stringWithFormat:@"%.0f %@", position.actualPrice, [Compatibility currencySymbol]];
    
    if(self.type == DBPositionCellTypeFull){
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

- (IBAction)orderButtonPressed:(id)sender {
    [self animateAdditionWithCompletion:^{
        [self.delegate positionCellDidOrder:self];
        
        [GANHelper analyzeEvent:@"item_product_add_to_order"
                          label:self.position.positionId
                       category:@"Menu_screen"];
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

@end
