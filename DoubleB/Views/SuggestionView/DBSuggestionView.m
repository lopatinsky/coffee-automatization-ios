//
//  ShareSuggestionView.m
//  
//
//  Created by Balaban Alexander on 03/09/15.
//
//

#import "DBSuggestionView.h"

@interface DBSuggestionView ()
@property (weak, nonatomic) IBOutlet UIImageView *closeButtonImageView;
@property (strong, nonatomic) IBOutlet UILabel *suggestTextLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@property (weak, nonatomic) UIView *viewHolder;
@end

@implementation DBSuggestionView

- (void)awakeFromNib {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnView)];
    [self addGestureRecognizer:tapGestureRecognizer];
    
    self.backgroundColor = [UIColor colorWithWhite:0.4f alpha:0.9f];
    self.separatorView.backgroundColor = [UIColor whiteColor];
    
    [self.closeButtonImageView templateImageWithName:@"close_white.png" tintColor:[UIColor whiteColor]];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    self.suggestTextLabel.text = title;
}

- (IBAction)closeViewButtonTapped:(id)sender {
    if([self.delegate respondsToSelector:@selector(closeSuggestionView:)])
        [self.delegate closeSuggestionView:self];
}

- (void)tapOnView {
    if([self.delegate respondsToSelector:@selector(clickSuggestionView:)])
        [self.delegate clickSuggestionView:self];
}

- (void)showOnView:(UIView *)view animated:(BOOL)animated {
    self.viewHolder = view;
    
    CGRect rect = self.frame;
    rect.origin.y = view.frame.size.height;
    rect.size.width = view.frame.size.width;
    self.frame = rect;
    
    [view addSubview:self];
    
    void (^block)(UIView*) = ^void(UIView *view) {
        CGRect rect = self.frame;
        rect.origin.y = view.frame.size.height - self.frame.size.height;
        self.frame = rect;
        
        [self layoutIfNeeded];
    };
    
    if(animated){
        [UIView animateWithDuration:0.2 animations:^{
            block(view);
        }];
    } else {
        block(view);
    }
}

- (void)hide:(BOOL)animated completion:(void(^)())completion {
    void (^block)(UIView*) = ^void(UIView *view) {
        CGRect rect = self.frame;
        rect.origin.y = view.frame.size.height;
        self.frame = rect;
        
        [self layoutIfNeeded];
    };
    
    if(animated){
        [UIView animateWithDuration:0.2 animations:^{
            block(self.viewHolder);
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            if(completion)
                completion();
        }];
    } else {
        [self removeFromSuperview];
        if(completion)
            completion();
    }
    self.viewHolder = nil;
}

@end
