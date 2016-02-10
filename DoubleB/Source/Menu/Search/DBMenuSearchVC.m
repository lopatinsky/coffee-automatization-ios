//
//  DBMenuSearchVC.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 10/02/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBMenuSearchVC.h"
#import "DBMenuSearchBarView.h"

@interface DBMenuSearchVC ()<UIViewControllerTransitioningDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) DBMenuSearchBarView *searchView;
@property (strong, nonatomic) UITableView *tableView;

@end

@implementation DBMenuSearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.searchView = [DBMenuSearchBarView create];
    [self.searchView.cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
//    self.searchView.searchBar.delegate = self;
    [self.view addSubview:self.searchView];
    
    self.tableView = [UITableView new];
//    self.tableView.dataSource = self;
//    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (void)present:(DBMenuSearchVC *)controller inContainer:(UIViewController *)container {
    controller.transitioningDelegate = controller;
    controller.modalPresentationStyle = UIModalPresentationCustom;
    
    [controller beginAppearanceTransition:YES animated:YES];
    [container presentViewController:controller animated:YES completion:^{
        [controller endAppearanceTransition];
    }];
}

- (void)cancelButtonClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UISearchBarDelegate

#pragma mark - UITableViewDataSource

#pragma mark - UITableViewDelegate

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
            CGRect rect = self.searchView.frame;
            rect.origin.y = -rect.size.height;
            self.searchView.frame = rect;
            
            self.tableView.alpha = 0;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    } else {
        CGRect searchViewRect = self.searchView.frame;
        searchViewRect.size.width = fromViewController.view.frame.size.width;
        searchViewRect.origin.y = -searchViewRect.size.height;
        self.searchView.frame = searchViewRect;
        
        CGRect tableRect = self.tableView.frame;
        tableRect.size.width = fromViewController.view.frame.size.width;
        tableRect.origin.y = self.searchView.frame.size.height;
        tableRect.size.height = fromViewController.view.frame.size.height - tableRect.origin.y;
        self.tableView.frame = tableRect;
        
        [[transitionContext containerView] addSubview:toViewController.view];
        
        self.tableView.alpha = 0;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            CGRect rect = self.searchView.frame;
            rect.origin.y = 0;
            self.searchView.frame = rect;
            
            self.tableView.alpha = 1;
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

- (void)keyboardWillShow:(NSNotification *)notification{
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         CGRect rect = self.tableView.frame;
                         rect.size.height = self.view.frame.size.height - self.searchView.frame.size.height - keyboardRect.size.height;
                         self.tableView.frame = rect;
                     }
                     completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification{
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         CGRect rect = self.tableView.frame;
                         rect.size.height = self.view.frame.size.height - self.searchView.frame.size.height;
                         self.tableView.frame = rect;
                     }
                     completion:nil];
}

@end
