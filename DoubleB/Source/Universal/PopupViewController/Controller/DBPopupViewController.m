//
//  DBPopupViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 15/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBPopupViewController.h"
#import "DBPopupHeaderView.h"
#import "DBPopupFooterView.h"

#import "UIGestureRecognizer+BlocksKit.h"

@interface DBPopupViewController ()
@property (strong, nonatomic) UIImageView *bgImageView;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIView *headerFooterView;

@end

@implementation DBPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bgImageView = [UIImageView new];
    @weakify(self)
    UITapGestureRecognizer *tapRecognizer = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self)
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [self.bgImageView addGestureRecognizer:tapRecognizer];
    self.bgImageView.userInteractionEnabled = YES;
    
    self.contentView = [UIView new];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.contentView.layer.cornerRadius = 6.f;
    self.contentView.layer.masksToBounds = YES;
    
    if (_displayController) {
        [self addChildViewController:_displayController];
        [self.contentView addSubview:_displayController.view];
        [_displayController didMoveToParentViewController:self];
    } else if (_displayView) {
        [self.contentView addSubview:_displayView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_displayController) {
        [_displayController beginAppearanceTransition:YES animated:YES];
    }
}

- (void)configLayout:(CGRect)rect {
    self.bgImageView.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
    [self.view addSubview:self.bgImageView];
    
    if (self.appearanceMode == DBPopupVCAppearanceModeHeader) {
        DBPopupHeaderView *header = [DBPopupHeaderView create];
        @weakify(self)
        header.doneBlock = ^void() {
            @strongify(self)
            [self dismissViewControllerAnimated:YES completion:nil];
        };
        self.headerFooterView = header;
        
        int height = rect.size.height - 50 - self.headerFooterView.frame.size.height;
        
        if (_displayController) {
            if ([_displayController respondsToSelector:@selector(db_popupContentContentHeight)]) {
                height = [_displayController db_popupContentContentHeight];
            }
        } else if (_displayView) {
            if ([_displayView respondsToSelector:@selector(db_popupContentContentHeight)]) {
                height = [_displayView db_popupContentContentHeight];
            }
        }
        
        [self.view addSubview:self.contentView];
        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView alignLeading:@"5" trailing:@"-5" toView:self.view];
        [self.contentView alignBottomEdgeWithView:self.view predicate:@"-10"];
        [self.contentView constrainHeight:[NSString stringWithFormat:@"%ld", (long)height]];
        
        [self.view addSubview:self.headerFooterView];
        self.headerFooterView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.headerFooterView alignLeading:@"5" trailing:@"-5" toView:self.view];
        [self.headerFooterView constrainBottomSpaceToView:self.contentView predicate:@"0"];
        [self.headerFooterView constrainHeight:[NSString stringWithFormat:@"%ld", (long)self.headerFooterView.frame.size.height]];
    }
    
    if (self.appearanceMode == DBPopupVCAppearanceModeFooter) {
        DBPopupFooterView *footer = [DBPopupFooterView create];
        @weakify(self)
        footer.doneBlock = ^void() {
            @strongify(self)
            [self dismissViewControllerAnimated:YES completion:nil];
        };
        self.headerFooterView = footer;
        
        [self.view addSubview:self.contentView];
        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.view addSubview:self.headerFooterView];
        self.headerFooterView.translatesAutoresizingMaskIntoConstraints = NO;
        
        int height = rect.size.height - 60 - self.headerFooterView.frame.size.height;
        if (_displayController) {
            if ([_displayController respondsToSelector:@selector(db_popupContentContentHeight)]) {
                height = [_displayController db_popupContentContentHeight];
            }
        } else if (_displayView) {
            if ([_displayView respondsToSelector:@selector(db_popupContentContentHeight)]) {
                height = [_displayView db_popupContentContentHeight];
            }
        }
        
        [self.contentView alignLeading:@"5" trailing:@"-5" toView:self.view];
        [self.contentView alignCenterYWithView:self.view predicate:@"0"];
//        [self.contentView alignTopEdgeWithView:self.view predicate:@"35"];
        [self.contentView constrainBottomSpaceToView:self.headerFooterView predicate:@"0"];
        [self.contentView constrainHeight:[NSString stringWithFormat:@"%ld", (long)height]];
        
        [self.headerFooterView alignLeading:@"5" trailing:@"-5" toView:self.view];
        [self.headerFooterView constrainHeight:[NSString stringWithFormat:@"%ld", (long)self.headerFooterView.frame.size.height]];
//        [self.headerFooterView alignBottomEdgeWithView:self.view predicate:@"-25"];
    }
    
    if (_displayController) {
        _displayController.view.frame = self.contentView.bounds;
    } else if (_displayView) {
        _displayView.frame = self.contentView.bounds;
    }
}


#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.2;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    BOOL reversed = fromViewController == self;
    
    toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
    
    if (reversed) {
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromViewController.view.alpha = 0;
            
            self.contentView.transform = CGAffineTransformMakeScale(0.8, 0.8);
            self.headerFooterView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        } completion:^(BOOL finished) {
            if (_displayController) {
                [_displayController removeFromParentViewController];
                [_displayController.view removeFromSuperview];
            } else if (_displayView) {
                [_displayView removeFromSuperview];
            }
            
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    } else {
        [self configLayout:toViewController.view.frame];
        
        [[transitionContext containerView] addSubview:toViewController.view];
        toViewController.view.alpha = 0;
        
        UIImage *snapshot = [fromViewController.view snapshotImage];
        self.bgImageView.image = [snapshot applyBlurWithRadius:5 tintColor:[UIColor colorWithWhite:0.3 alpha:0.6] saturationDeltaFactor:1.5 maskImage:nil];
        self.contentView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        self.headerFooterView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            toViewController.view.alpha = 1;
            
            self.contentView.transform = CGAffineTransformIdentity;
            self.headerFooterView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
}

@end

