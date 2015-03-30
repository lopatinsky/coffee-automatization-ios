//
//  IHProductTableViewCell.m
//  IIko Hackathon
//
//  Created by Balaban Alexander on 04/04/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBPositionCell.h"
#import "DBMenuPosition.h"

#import "UIImageView+WebCache.h"

@interface DBPositionCell()

@end

@implementation DBPositionCell

- (void)awakeFromNib
{
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor whiteColor];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.positionImageView.image = [UIImage imageNamed:@"noimage_icon.png"];
    self.positionImageView.backgroundColor = [UIColor colorWithRed:200./255 green:200./255 blue:200./255 alpha:0.3f];
    self.positionDefaultImageView.hidden = NO;
    
    self.priceLabel.backgroundColor = [UIColor db_defaultColor];
    self.priceLabel.layer.cornerRadius = self.priceLabel.frame.size.height / 2;
    self.priceLabel.layer.masksToBounds = YES;
    self.priceLabel.textColor = [UIColor whiteColor];
    
    self.separatorView.backgroundColor = [UIColor db_separatorColor];
}

- (void)configureWithPosition:(DBMenuPosition *)position{
    self.position = position;
    
    self.titleLabel.text = position.name;
    self.descriptionLabel.text = position.positionDescription;
    
    self.priceLabel.text = [NSString stringWithFormat:@"%.0f р.", position.price];
    
    if(position.weight == 0){
        self.weightLabel.hidden = YES;
    } else {
        self.weightLabel.text = [NSString stringWithFormat:@"%.0f г", position.weight * 1000];
        self.weightLabel.hidden = NO;
    }
    
    if(position.imageUrl){
        [self.positionImageView sd_setImageWithURL:[NSURL URLWithString:@"http://teplich35.ru/wp-content/uploads/2014/08/kapusta1.jpg"]
                                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                if(!error){
                                                    self.positionImageView.backgroundColor = [UIColor clearColor];
                                                    self.positionDefaultImageView.hidden = YES;
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
                         view.transform = CGAffineTransformMakeScale(1.7, 1.7);
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
