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
#import "UIImageView+PINRemoteImage.h"

@interface DBCategoryHeaderView ()
@property (weak, nonatomic) IBOutlet UIView *categoryImageContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintCategoryImageContainerWidth;

@property (weak, nonatomic) IBOutlet UIImageView *categoryImageView;
@property (weak, nonatomic) IBOutlet UILabel *categoryTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@property (weak, nonatomic) IBOutlet UIView *arrowContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintArrowContainerViewWidth;


@property(nonatomic) CGFloat initialHeight;
@property(nonatomic) CGFloat initialCategoryImageContainerWidth;
@property(nonatomic) CGFloat initialArrowContainerViewWidth;
@end

@implementation DBCategoryHeaderView

- (instancetype)initWithMenuCategory:(DBMenuCategory *)category state:(DBCategoryHeaderViewState)state{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBCategoryHeaderView" owner:self options:nil] firstObject];
    self.initialHeight = self.frame.size.height;
    self.initialCategoryImageContainerWidth = self.constraintCategoryImageContainerWidth.constant;
    self.initialArrowContainerViewWidth = self.constraintArrowContainerViewWidth.constant;
    
    self.category = category;
    [self changeState:state animated:NO];
    [self setCategoryOpened:NO animated:NO];
    
    [self commonInit];
    
    return self;
}

- (void)commonInit{
    self.backgroundColor = [UIColor whiteColor];
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.categoryTitleLabel.textColor = [UIColor blackColor];
    self.categoryTitleLabel.text = self.category.name;
    
    if(self.category.imageUrl) {
        [self.categoryImageView sd_setImageWithURL:[NSURL URLWithString:self.category.imageUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (!error){
                [self.categoryImageView db_hideDefaultImage];
            }
        }];
//        self.categoryImageView.image = nil;
//        [self.categoryImageView setPin_updateWithProgress:YES];
//        [self.categoryImageView pin_setImageFromURL:[NSURL URLWithString:self.category.imageUrl] completion:^(PINRemoteImageManagerResult *result) {
//            if (result.resultType != PINRemoteImageResultTypeNone) {
//                [self.categoryImageView db_hideDefaultImage];
//            }
//        }];
    }
    
    self.separatorView.backgroundColor = [UIColor db_separatorColor];
    
    @weakify(self)
    [self addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self)
        if([self.delegate respondsToSelector:@selector(db_categoryHeaderViewDidSelect:)]){
            [self.delegate db_categoryHeaderViewDidSelect:self];
        }
    }]];
    
    self.arrowContainerView.backgroundColor = [UIColor clearColor];
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
                self.categoryTitleLabel.textAlignment = NSTextAlignmentCenter;
            } else {
                self.backgroundColor = [UIColor whiteColor];
                self.categoryTitleLabel.textColor = [UIColor blackColor];
                self.categoryTitleLabel.textAlignment = NSTextAlignmentLeft;
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
    }
}

- (void)setCategoryOpened:(BOOL)categoryOpened animated:(BOOL)animated{
    void (^viewConfig)() = ^void(){
        if(categoryOpened){
            self.constraintArrowContainerViewWidth.constant = 0;
        } else {
            self.constraintArrowContainerViewWidth.constant = self.initialArrowContainerViewWidth;
        }
    };
    
    if(animated){
        [UIView animateWithDuration:0.3 animations:^{
            viewConfig();
            [self layoutIfNeeded];
        }];
    } else {
        viewConfig();
    }
}

- (CGFloat)viewHeight{
    return self.state == DBCategoryHeaderViewStateFull ? self.initialHeight : 40.f;
}



@end
