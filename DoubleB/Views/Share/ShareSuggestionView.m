//
//  ShareSuggestionView.m
//  
//
//  Created by Balaban Alexander on 03/09/15.
//
//

#import "ShareSuggestionView.h"

@implementation ShareSuggestionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnView)];
    [self addGestureRecognizer:tapGestureRecognizer];
    
    self.closeButton.imageView.image = [UIImage imageNamed:@"close_white.png"];
    return self;
}

- (IBAction)closeViewButtonTapped:(id)sender {
    [self.delegate hideShareSuggestionView];
}

- (void)tapOnView {
    [self.delegate showShareViewController];
}

@end
