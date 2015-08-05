//
//  IHCategoryTableViewCell.m
//  IIko Hackathon
//
//  Created by Balaban Alexander on 04/04/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBCategoryCell.h"
#import "DBMenuCategory.h"

#import "UIImageView+WebCache.h"

@interface DBCategoryCell ()<UIGestureRecognizerDelegate>
@end

@implementation DBCategoryCell

- (instancetype)init{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBCategoryCell" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor whiteColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.categoryIconImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.disclosureIndicator.tintColor = [UIColor db_defaultColor];
    [self.disclosureIndicator templateImageWithName:@"right_arrow_icon.png"];
    
    self.separatorView.backgroundColor = [UIColor db_separatorColor];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    tapGestureRecognizer.delegate = self;
    [self addGestureRecognizer:tapGestureRecognizer];
}

- (void)configureWithCategory:(DBMenuCategory *)category{
    _category = category;
    
    [self.categoryIconImageView db_showDefaultImage];
    [self.categoryIconImageView sd_setImageWithURL:[NSURL URLWithString:category.imageUrl]
                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                         if(!error){
                                             [self.categoryIconImageView db_hideDefaultImage];
                                         }
                                     }];
    self.categoryNameLabel.text = category.name;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    CGPoint touchPoint = [touch locationInView:self];
    
    if(CGRectContainsPoint(self.categoryIconImageView.frame, touchPoint)){
        [GANHelper analyzeEvent:@"item_category_logo_click" label:self.category.categoryId category:CATEGORIES_SCREEN];
    }
    
    if(CGRectContainsPoint(self.categoryNameLabel.frame, touchPoint)){
        [GANHelper analyzeEvent:@"item_category_title_click" label:self.category.categoryId category:CATEGORIES_SCREEN];
    }
    
    if(CGRectContainsPoint(self.disclosureIndicator.frame, touchPoint)){
        [GANHelper analyzeEvent:@"item_category_disclosure_indicator_click" label:self.category.categoryId category:CATEGORIES_SCREEN];
    }
    
    
    return NO;
}

@end
