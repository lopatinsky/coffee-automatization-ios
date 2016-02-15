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

@interface DBPopupViewController ()<UIViewControllerTransitioningDelegate>
@property (strong, nonatomic) UIImageView *bgImageView;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIView *headerFooterView;

@property (weak, nonatomic) NSLayoutConstraint *constraintTopSpace;
@property (weak, nonatomic) NSLayoutConstraint *constraintBottomSpace;
@property (weak, nonatomic) NSLayoutConstraint *constraintCenterYAlignment;

@property (nonatomic) CGFloat minTopOffset;
@property (nonatomic) CGFloat minBottomOffset;
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
        _displayController.view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_displayController.view];
        [_displayController.view alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self.contentView];
        
        [_displayController didMoveToParentViewController:self];
    } else if (_displayView) {
        _displayView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_displayView];
        [_displayView alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self.contentView];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_displayController) {
        [_displayController viewWillAppear:animated];
//        [_displayController beginAppearanceTransition:YES animated:YES];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    }
    
     if (self.appearanceMode == DBPopupVCAppearanceModeFooter) {
        DBPopupFooterView *footer = [DBPopupFooterView create];
        @weakify(self)
        footer.doneBlock = ^void() {
            @strongify(self)
            [self dismissViewControllerAnimated:YES completion:nil];
        };
        self.headerFooterView = footer;
    }
    
    int maxHeight = 0;
    int height = 0;
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
    
    [self.view addSubview:self.headerFooterView];
    self.headerFooterView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.headerFooterView alignLeading:@"5" trailing:@"-5" toView:self.view];
    [self.headerFooterView constrainHeight:[NSString stringWithFormat:@"%ld", (long)self.headerFooterView.frame.size.height]];
    
    if (self.appearanceMode == DBPopupVCAppearanceModeHeader) {
        self.minTopOffset = 40.f;
        self.minBottomOffset = 10.f;
        
        maxHeight = rect.size.height - self.headerFooterView.frame.size.height - self.minTopOffset - self.minBottomOffset;
        if (height == 0)
            height = maxHeight;
        
        
        [self.contentView constrainHeight:[NSString stringWithFormat:@"%ld", (long)height]];
        [self.headerFooterView constrainBottomSpaceToView:self.contentView predicate:@"0"];
        
        if (height != maxHeight) {
            self.constraintCenterYAlignment = [[self.contentView alignCenterYWithView:self.view predicate:@"20"] firstObject];
        } else {
            self.constraintBottomSpace = [[self.contentView alignBottomEdgeWithView:self.view predicate:[NSString stringWithFormat:@"-%.0f", self.minBottomOffset]] firstObject];
        }
    }
    
    if (self.appearanceMode == DBPopupVCAppearanceModeFooter) {
        maxHeight = rect.size.height - self.headerFooterView.frame.size.height - self.minTopOffset - self.minBottomOffset;
        if (height == 0)
            height = maxHeight;
        
        self.constraintCenterYAlignment = [[self.contentView alignCenterYWithView:self.view predicate:@"0"] firstObject];
        [self.contentView constrainBottomSpaceToView:self.headerFooterView predicate:@"0"];
        [self.contentView constrainHeight:[NSString stringWithFormat:@"%ld", (long)height]];
    }
}

- (void)moveToInitialPosition:(double)time {
    if (self.appearanceMode == DBPopupVCAppearanceModeHeader) {
        if (self.constraintCenterYAlignment && self.constraintCenterYAlignment.constant != 20) {
            [UIView animateWithDuration:time animations:^{
                self.constraintCenterYAlignment.constant = 20;
                [self.view layoutIfNeeded];
            }];
        }
    }
    
    if (self.appearanceMode == DBPopupVCAppearanceModeFooter) {
        if (self.constraintCenterYAlignment && self.constraintCenterYAlignment.constant != 0) {
            [UIView animateWithDuration:time animations:^{
                self.constraintCenterYAlignment.constant = 0;
                [self.view layoutIfNeeded];
            }];
        }
    }
}

- (void)moveToPositionHigherThan:(CGFloat)bottomOffset time:(double)time {
    if (self.appearanceMode == DBPopupVCAppearanceModeHeader) {
        BOOL canMove = self.constraintCenterYAlignment != nil;
        
        CGFloat difference = bottomOffset - (self.view.frame.size.height - (self.contentView.frame.origin.y + self.contentView.frame.size.height));
        canMove = canMove && difference > 0;
        
        CGFloat possibleDifference = self.headerFooterView.frame.origin.y - difference >= self.minTopOffset ? difference : self.headerFooterView.frame.origin.y - self.minTopOffset;
        canMove = canMove && possibleDifference > 0;
        
        if (canMove) {
            [UIView animateWithDuration:time animations:^{
                self.constraintCenterYAlignment.constant = 20 - possibleDifference;
                [self.view layoutIfNeeded];
            }];
        }
    }
    
    if (self.appearanceMode == DBPopupVCAppearanceModeFooter) {
        CGFloat difference = bottomOffset - (self.view.frame.size.height - (self.headerFooterView.frame.origin.y + self.headerFooterView.frame.size.height));
        BOOL canMove = difference > 0;
        
        CGFloat possibleDifference = self.contentView.frame.origin.y - difference >= self.minTopOffset ? difference : self.contentView.frame.origin.y - self.minTopOffset;
        canMove = canMove && possibleDifference > 0;
        
        if (canMove) {
            [UIView animateWithDuration:time animations:^{
                self.constraintCenterYAlignment.constant = -possibleDifference;
                [self.view layoutIfNeeded];
            }];
        }
    }
}



+ (void)presentController:(UIViewController<DBPopupViewControllerContent> *)controller
              inContainer:(UIViewController *)container
                     mode:(DBPopupVCAppearanceMode)mode {
    DBPopupViewController *popupVC = [DBPopupViewController new];
    popupVC.displayController = controller;
    popupVC.appearanceMode = mode;
    popupVC.transitioningDelegate = popupVC;
    popupVC.modalPresentationStyle = UIModalPresentationCustom;
    
    [popupVC beginAppearanceTransition:YES animated:YES];
    [container presentViewController:popupVC animated:YES completion:^{
        [popupVC endAppearanceTransition];
    }];
}


+ (void)presentView:(UIView<DBPopupViewControllerContent> *)view
        inContainer:(UIViewController *)container
               mode:(DBPopupVCAppearanceMode)mode {
    DBPopupViewController *popupVC = [DBPopupViewController new];
    popupVC.displayView = view;
    popupVC.appearanceMode = mode;
    popupVC.transitioningDelegate = popupVC;
    popupVC.modalPresentationStyle = UIModalPresentationCustom;
    
    [popupVC beginAppearanceTransition:YES animated:YES];
    [container presentViewController:popupVC animated:YES completion:^{
        [popupVC endAppearanceTransition];
    }];
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
            self.headerFooterView.transform = CGAffineTransformMakeScale(0.6, 0.6);
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
        self.headerFooterView.transform = CGAffineTransformMakeScale(0.6, 0.6);
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            toViewController.view.alpha = 1;
            
            self.contentView.transform = CGAffineTransformIdentity;
            self.headerFooterView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
}


#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

#pragma mark - Keyboard events

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [self moveToPositionHigherThan:keyboardRect.size.height + 5 time:0.25];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self moveToInitialPosition:0.25];
}

@end

