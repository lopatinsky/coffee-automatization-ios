//
//  DBMenuCategoryDropdownTitleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 03/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBDropdownTitleView.h"

@interface DBDropdownTitleView ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;

@end

@implementation DBDropdownTitleView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBDropdownTitleView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    self.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = [UIColor whiteColor];
    
    [self.arrowImageView templateImageWithName:@"arrow_horizontal_icon.png" tintColor:[UIColor whiteColor]];
    _state = DBDropdownTitleViewStateClosed;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognizerHandler:)];
    tapRecognizer.cancelsTouchesInView = NO;
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tapRecognizer];
}

- (void)setState:(DBDropdownTitleViewState)state {
    _state = state;
    
    if (state == DBDropdownTitleViewStateNone) {
        self.arrowImageView.hidden = YES;
    } else {
        self.arrowImageView.hidden = NO;
        
        [UIView animateWithDuration:0.1 animations:^{
            self.arrowImageView.alpha = 0.f;
        } completion:^(BOOL finished) {
            if (state == DBDropdownTitleViewStateOpened) {
                [self.arrowImageView templateImageWithName:@"arrow_horizontal_top_icon.png" tintColor:[UIColor whiteColor]];
            } else {
                [self.arrowImageView templateImageWithName:@"arrow_horizontal_icon.png" tintColor:[UIColor whiteColor]];
            }
            
            [UIView animateWithDuration:0.1 animations:^{
                self.arrowImageView.alpha = 1.f;
            }];
        }];
    }
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    [UIView animateWithDuration:0.1 animations:^{
        self.titleLabel.alpha = 0.f;
    } completion:^(BOOL finished) {
        self.titleLabel.text = title;
        
        [UIView animateWithDuration:0.1 animations:^{
            self.titleLabel.alpha = 1.f;
        }];
    }];
}

- (void)tapRecognizerHandler:(UITapGestureRecognizer *)recognizer {
    if ([self.delegate respondsToSelector:@selector(db_dropdownTitleClick:)]) {
        [self.delegate db_dropdownTitleClick:self];
    }
}

@end
