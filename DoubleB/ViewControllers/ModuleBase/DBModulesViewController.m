//
//  DBModulesViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 17.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBModulesViewController.h"
#import "DBModuleView.h"

@interface DBModulesViewController ()
@property (strong, nonatomic) UIScrollView *scrollView;

@property (weak, nonatomic) NSLayoutConstraint *constraintBottomScrollViewAlignment;

@end

@implementation DBModulesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.modules = [NSMutableArray new];
    [self configLayout];
    
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
    
    for (DBModuleView *submodule in self.modules) {
        [submodule viewWillAppearOnVC];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    for (DBModuleView *submodule in self.modules) {
        [submodule viewDidAppearOnVC];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    for (DBModuleView *submodule in self.modules) {
        [submodule viewWillDissapearFromVC];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configLayout {
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.scrollEnabled = YES;
    [self.view addSubview:_scrollView];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView alignTop:@"0" leading:@"0" toView:self.view];
    [_scrollView alignTrailingEdgeWithView:self.view predicate:@"0"];
    self.constraintBottomScrollViewAlignment = [[_scrollView alignBottomEdgeWithView:self.view predicate:@"0"] firstObject];
}

- (void)setAnalyticsCategory:(NSString *)analyticsCategory {
    _analyticsCategory = analyticsCategory;
    
    for (DBModuleView *moduleView in self.modules) {
        moduleView.analyticsCategory = _analyticsCategory;
    }
}

- (void)addModule:(DBModuleView *)moduleView {
    moduleView.analyticsCategory = self.analyticsCategory;
    moduleView.ownerViewController = self;
    
    [self.modules addObject:moduleView];
    
    [moduleView viewAddedOnVC];
}

- (void)removeModule:(DBModuleView *)moduleView {
    [self.modules removeObject:moduleView];
}

- (void)layoutModules {
    for (int i = 0; i < self.modules.count; i++){
        UIView *moduleView = self.modules[i];
        
        [_scrollView addSubview:moduleView];
        moduleView.translatesAutoresizingMaskIntoConstraints = NO;
        [moduleView alignLeadingEdgeWithView:_scrollView predicate:@"0"];
        [moduleView alignTrailingEdgeWithView:_scrollView predicate:@"0"];
//        [moduleView constrainHeight:[NSString stringWithFormat:@"%.f", moduleView.frame.size.height]];
        
        if(i == 0){
            [moduleView alignTopEdgeWithView:_scrollView predicate:@"0"];
            
            [moduleView alignLeadingEdgeWithView:self.view predicate:@"0"];
            [moduleView alignTrailingEdgeWithView:self.view predicate:@"0"];
        } else {
            UIView *topView = self.modules[i-1];
            [moduleView constrainTopSpaceToView:topView predicate:@"0"];
            
            if (i == self.modules.count - 1) {
                [moduleView alignBottomEdgeWithView:_scrollView predicate:@">=0"];
                [moduleView alignBottomEdgeWithView:_scrollView predicate:@"0@900"];
            }
        }
    }
    
}

- (void)reloadModules:(BOOL)animated {
    for (DBModuleView *module in self.modules){
        [module reload:animated];
    }
}

#pragma mark - Keyboard events

- (void)keyboardWillShow:(NSNotification *)notification{
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.constraintBottomScrollViewAlignment.constant = -keyboardRect.size.height;
                         [self.view layoutIfNeeded];
                     }
                     completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification{
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.constraintBottomScrollViewAlignment.constant = 0;
                         [self.view layoutIfNeeded];
                     }
                     completion:nil];
}

@end
