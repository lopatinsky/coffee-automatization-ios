//
//  ShareSuggestionView.m
//  
//
//  Created by Balaban Alexander on 03/09/15.
//
//

#import "ShareSuggestionView.h"
#import "DBShareHelper.h"

@interface ShareSuggestionView ()
@property (weak, nonatomic) IBOutlet UIImageView *closeButtonImageView;
@property (strong, nonatomic) IBOutlet UILabel *suggestTextLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@property (weak, nonatomic) UIView *viewHolder;
@end

@implementation ShareSuggestionView

- (void)awakeFromNib {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnView)];
    [self addGestureRecognizer:tapGestureRecognizer];
    
    self.backgroundColor = [UIColor colorWithWhite:0.4f alpha:0.9f];
    self.separatorView.backgroundColor = [UIColor whiteColor];
    
    self.suggestTextLabel.text = [DBShareHelper sharedInstance].titleShareScreen;
    
    [self.closeButtonImageView templateImageWithName:@"close_white.png" tintColor:[UIColor whiteColor]];
}

- (IBAction)closeViewButtonTapped:(id)sender {
    [self.delegate hideShareSuggestionView];
}

- (void)tapOnView {
    [self.delegate showShareViewController];
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

- (void)hide:(BOOL)animated {
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
        }];
    } else {
        [self removeFromSuperview];
    }
    self.viewHolder = nil;
}

@end
