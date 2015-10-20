//
//  DBPaymentModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 19.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBModuleView.h"

@interface DBModuleView ()

@end

@implementation DBModuleView

- (instancetype)init {
    self = [super initWithFrame:CGRectMake(0, 0, 320, 40)];
    
    [self commomInit];
    
    return self;
}

- (void)awakeFromNib {
    [self commomInit];
}

- (void)commomInit {
    self.submodules = [NSMutableArray new];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognizerHandler:)];
    tapRecognizer.cancelsTouchesInView = NO;
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tapRecognizer];
}

#pragma mark - Layout & Reload

- (void)layoutModules {
    for (int i = 0; i < self.submodules.count; i++){
        UIView *moduleView = self.submodules[i];
        
        [self addSubview:moduleView];
        moduleView.translatesAutoresizingMaskIntoConstraints = NO;
        [moduleView alignLeadingEdgeWithView:self predicate:@"0"];
        [moduleView alignTrailingEdgeWithView:self predicate:@"0"];
        
        if(i == 0){
            [moduleView alignTopEdgeWithView:self predicate:@"0"];
            
            [moduleView alignLeadingEdgeWithView:self predicate:@"0"];
            [moduleView alignTrailingEdgeWithView:self predicate:@"0"];
        } else {
            UIView *topView = self.submodules[i-1];
            [moduleView constrainTopSpaceToView:topView predicate:@"0"];
        }
    }
    
    [self reload:NO];
}

- (void)reload {
    [self reload:YES];
}

- (void)reload:(BOOL)animated {
    for(DBModuleView *module in _submodules){
        [module reload:animated];
    }
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            [self invalidateIntrinsicContentSize];
            [self.superview layoutIfNeeded];
        }];
    } else {
        [self invalidateIntrinsicContentSize];
        [self layoutIfNeeded];
    }
}

#pragma mark - Lifecicle

- (void)viewAddedOnVC {
    [self reload:NO];
    
    for (DBModuleView *submodule in self.submodules) {
        [submodule viewAddedOnVC];
    }
}

- (void)viewWillAppearOnVC {
    for (DBModuleView *submodule in self.submodules) {
        [submodule viewWillAppearOnVC];
    }
}

- (void)viewDidAppearOnVC {
    for (DBModuleView *submodule in self.submodules) {
        [submodule viewDidAppearOnVC];
    }
}

- (void)viewWillDissapearFromVC {
    for (DBModuleView *submodule in self.submodules) {
        [submodule viewWillDissapearFromVC];
    }
}

#pragma mark - Setters

- (void)setAnalyticsCategory:(NSString *)analyticsCategory{
    _analyticsCategory = analyticsCategory;
    
    for(DBModuleView *submodule in _submodules){
        submodule.analyticsCategory = analyticsCategory;
    }
}

- (void)setOwnerViewController:(UIViewController *)ownerViewController{
    _ownerViewController = ownerViewController;
    
    for(DBModuleView *submodule in _submodules){
        submodule.ownerViewController = ownerViewController;
    }
}

#pragma mark - Size

- (CGSize)intrinsicContentSize {
    return [self moduleViewContentSize];
}


- (CGSize)moduleViewContentSize {
    return CGSizeMake(self.frame.size.width, [self moduleViewContentHeight]);
}

- (CGFloat)moduleViewContentHeight {
    int height = self.frame.size.height;
    
    if(_submodules.count > 0) {
        height = 0;
        for(DBModuleView *module in _submodules)
            height += module.moduleViewContentSize.height;
    }
    
    return CGSizeMake(UIViewNoIntrinsicMetric, height);
    return height;
}

#pragma mark - Touches

- (void)tapRecognizerHandler:(UITapGestureRecognizer *)recognizer {
    [self touchAtLocation:[recognizer locationInView:self]];
}

- (void)touchAtLocation:(CGPoint)location {
    
}

@end
