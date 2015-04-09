//
//  DBCategoryHeaderView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 30.03.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBCategoryHeaderView.h"
#import "DBMenuCategory.h"

#import "UIImageView+WebCache.h"
#import "UIGestureRecognizer+BlocksKit.h"

@interface DBCategoryHeaderView ()
@property (weak, nonatomic) IBOutlet UIView *categoryImageContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintCategoryImageContainerWidth;

@property (weak, nonatomic) IBOutlet UIImageView *categoryImageView;
@property (weak, nonatomic) IBOutlet UILabel *categoryTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@property (weak, nonatomic) IBOutlet UIView *categorySelectionView;
@property (weak, nonatomic) IBOutlet UIImageView *categorySelectionImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintCategorySelectionViewWidth;

@property(nonatomic) CGFloat initialHeight;
@property(nonatomic) CGFloat initialCategoryImageContainerWidth;
@property(nonatomic) CGFloat initialSelectionViewWidth;
@end

@implementation DBCategoryHeaderView

- (instancetype)initWithMenuCategory:(DBMenuCategory *)category state:(DBCategoryHeaderViewState)state{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBCategoryHeaderView" owner:self options:nil] firstObject];
    self.initialHeight = self.frame.size.height;
    self.initialCategoryImageContainerWidth = self.constraintCategoryImageContainerWidth.constant;
    self.initialSelectionViewWidth = self.constraintCategorySelectionViewWidth.constant;
    
    self.category = category;
    [self changeState:state animated:NO];
    [self hideAccessoryView:NO];
    
    [self commonInit];
    
    return self;
}

- (void)commonInit{
    self.backgroundColor = [UIColor whiteColor];
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self.categoryImageView db_showDefaultImage];
    
    self.categoryTitleLabel.textColor = [UIColor blackColor];
    self.categoryTitleLabel.text = self.category.name;
    
    if(self.category.imageUrl){
        [self.categoryImageView sd_setImageWithURL:[NSURL URLWithString:self.category.imageUrl]
                                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                             if(!error){
                                                 [self.categoryImageView db_hideDefaultImage];
                                             }
                                         }];
    }
    
    self.separatorView.backgroundColor = [UIColor db_separatorColor];
    
    [self addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        if(CGRectContainsPoint(self.categorySelectionView.frame, location)){
            if([self.delegate respondsToSelector:@selector(db_categoryHeaderViewDidSelectCategoryChoice:)]){
                [self.delegate db_categoryHeaderViewDidSelectCategoryChoice:self];
            }
        } else {
            if([self.delegate respondsToSelector:@selector(db_categoryHeaderViewDidSelect:)]){
                [self.delegate db_categoryHeaderViewDidSelect:self];
            }
        }
    }]];
}

- (void)changeState:(DBCategoryHeaderViewState)state animated:(BOOL)animated{
    if(self.state != state){
        _state = state;
        
        void (^viewConfig)(DBCategoryHeaderViewState) = ^void(DBCategoryHeaderViewState state){
            self.constraintCategoryImageContainerWidth.constant = state == DBCategoryHeaderViewStateCompact ? 0 : self.initialCategoryImageContainerWidth;
            self.categoryImageView.alpha = state == DBCategoryHeaderViewStateCompact ? 0 : 1;
            
            CGRect rect = self.frame;
            rect.size.height = state == DBCategoryHeaderViewStateFull ? self.initialHeight : 40.f;
            self.frame = rect;
            
            if(state == DBCategoryHeaderViewStateCompact){
                self.backgroundColor = [UIColor db_defaultColorWithAlpha:0.9];
                self.categoryTitleLabel.textColor = [UIColor whiteColor];
                [self.categorySelectionImageView templateImageWithName:@"category_selection_icon.png" tintColor:[UIColor whiteColor]];
            } else {
                self.backgroundColor = [UIColor whiteColor];
                self.categoryTitleLabel.textColor = [UIColor blackColor];
                self.categorySelectionImageView.image = [UIImage imageNamed:@"category_selection_icon.png"];
            }
        };
        
        if(animated){
            [UIView animateWithDuration:0.3 animations:^{
                viewConfig(state);
                [self layoutIfNeeded];
            }];
        } else {
            viewConfig(state);
        }
        
        if(state == DBCategoryHeaderViewStateFull){
            [self hideAccessoryView:animated];
        }
    }
}

- (void)showAccessoryView:(BOOL)animated{
    void (^viewConfig)(DBCategoryHeaderViewState) = ^void(DBCategoryHeaderViewState state){
        self.constraintCategorySelectionViewWidth.constant = state == DBCategoryHeaderViewStateCompact ? self.initialSelectionViewWidth : 0;
        self.categorySelectionView.alpha = state == DBCategoryHeaderViewStateFull ? 0 : 1;
        [self layoutIfNeeded];
    };
    if(animated){
        [UIView animateWithDuration:0.3 animations:^{ viewConfig(self.state); }];
    } else {
        viewConfig(self.state);
    }
    
}

- (void)hideAccessoryView:(BOOL)animated{
    void (^viewConfig)() = ^void(){
        self.constraintCategorySelectionViewWidth.constant = 0;
        self.categorySelectionView.alpha = 0;
        [self layoutIfNeeded];
    };
    
    if(animated){
        [UIView animateWithDuration:0.3 animations:^{ viewConfig(); }];
    } else {
        viewConfig();
    }
}

- (CGFloat)viewHeight{
    return self.state == DBCategoryHeaderViewStateFull ? self.initialHeight : 40.f;
}



@end
