//
//  DBPositionPriceView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 09/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBPositionPriceView.h"
#import "UIView+RoundedCorners.h"

@interface DBPositionPriceView ()
@property (weak, nonatomic) IBOutlet UIButton *priceButton;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintPriceLabelWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintPriceLabelHeight;

@property (weak, nonatomic) IBOutlet UIImageView *basketImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *basketImageWidth;

@end

@implementation DBPositionPriceView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"DBPositionPriceView" owner:self options:nil] firstObject];
    
    [self addSubview:view];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [view alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self];
    
    return self;
}

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBPositionPriceView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    self.backgroundColor = [UIColor clearColor];
    self.priceLabel.backgroundColor = [UIColor db_defaultColor];
    [self.priceLabel setRoundedCorners];
    
    [self.priceButton addTarget:self action:@selector(priceButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *basketImage = [ViewManager basketImageMenuPosition];
    if (basketImage) {
        self.basketImageView.hidden = NO;
        self.basketImageWidth.constant = 24.0;
        self.basketImageView.image = [basketImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.basketImageView.tintColor = [UIColor db_defaultColor];
    } else {
        self.basketImageView.hidden = YES;
        self.basketImageWidth.constant = 0.0;
    }
}

- (void)priceButtonClick {
    if(_touchAction)
        _touchAction();
}

- (void)setMode:(DBPositionPriceViewMode)mode {
    _mode = mode;
    
    if(mode == DBPositionPriceViewModeInteracted) {
        [self.priceLabel setRoundedCorners];
        self.priceLabel.backgroundColor = [UIColor db_defaultColor];
        self.priceLabel.textColor = [UIColor whiteColor];
        
        self.priceButton.enabled = YES;
    } else {
        self.priceLabel.backgroundColor = [UIColor clearColor];
        self.priceLabel.textColor = [UIColor db_defaultColor];
        
        self.priceButton.enabled = NO;
    }
}

- (void)setTitle:(NSString *)title{
    _title = title;
    
    self.priceLabel.text = title;
}

- (void)setSize:(CGSize)size {
    self.constraintPriceLabelWidth.constant = size.width;
    self.constraintPriceLabelHeight.constant = size.height;
    
    [self layoutIfNeeded];
}

- (void)animatePositionAdditionWithCompletion:(void(^)())completion{
    UIView *view = [[UIView alloc] initWithFrame:self.priceLabel.frame];
    [view setRoundedCorners];
    view.backgroundColor = [UIColor db_defaultColor];
    
    [self addSubview:view];
    
    self.priceLabel.alpha = 0;
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
                         self.priceLabel.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         [view removeFromSuperview];
                     }];
}

@end
