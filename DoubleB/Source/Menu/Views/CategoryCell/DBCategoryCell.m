//
//  IHCategoryTableViewCell.m
//  IIko Hackathon
//
//  Created by Balaban Alexander on 04/04/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBCategoryCell.h"
#import "DBMenuCategory.h"

@interface DBCategoryCell ()<UIGestureRecognizerDelegate>
@end

@implementation DBCategoryCell

+ (instancetype)create:(DBCategoryCellAppearanceType)type {
    DBCategoryCell *cell = nil;
    
    if (type == DBCategoryCellAppearanceTypeFull)
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DBCategoryCell" owner:self options:nil] firstObject];
    else
        cell =  [[[NSBundle mainBundle] loadNibNamed:@"DBCategoryCompactCell" owner:self options:nil] firstObject];
    cell.appearanceType = type;
    
    return cell;
}

- (void)awakeFromNib {
    [self initOutlets];
    
    self.backgroundColor = [UIColor whiteColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.categoryIconImageView.contentMode = [ViewManager defaultMenuCategoryIconsContentMode];
    self.categoryIconImageView.noImageType = [DBCompanyInfo sharedInstance].type == DBCompanyTypeMobileShop ? DBImageViewNoImageTypeText : DBImageViewNoImageTypeImage;
    
    self.disclosureIndicator.tintColor = [UIColor db_defaultColor];
    [self.disclosureIndicator templateImageWithName:@"right_arrow_icon.png"];
    
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    tapGestureRecognizer.delegate = self;
    [self addGestureRecognizer:tapGestureRecognizer];
}

- (void)initOutlets {
    self.categoryIconImageView = (DBImageView *)[self.contentView viewWithTag:1];
    self.categoryNameLabel = (UILabel *)[self.contentView viewWithTag:2];
    self.disclosureIndicator = (UIImageView *)[self.contentView viewWithTag:3];
}

- (void)configureWithCategory:(DBMenuCategory *)category{
    _category = category;
    
    self.categoryIconImageView.dbImageUrl = [NSURL URLWithString:category.imageUrl];
//    self.categoryIconImageView.image = nil;
//    [self.categoryIconImageView db_showDefaultImage];
//    [self.categoryIconImageView setPin_updateWithProgress:YES];
//    [self.categoryIconImageView pin_setImageFromURL:[NSURL URLWithString:category.imageUrl] completion:^(PINRemoteImageManagerResult *result) {
//        if (result.resultType != PINRemoteImageResultTypeNone) {
//            [self.categoryIconImageView db_hideDefaultImage];
//        }
//    }];
    self.categoryNameLabel.text = category.name;
}

+ (CGFloat)height:(DBCategoryCellAppearanceType)type {
    if (type == DBCategoryCellAppearanceTypeFull) {
        return 90.f;
    } else {
        return 65.f;
    }
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
