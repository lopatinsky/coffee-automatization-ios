//
//  DBModulesViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 17.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBModulesViewController.h"

@interface DBModulesViewController ()
@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) NSMutableArray *modules;

@end

@implementation DBModulesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.modules = [NSMutableArray new];
    [self configLayout];
}

- (void)configLayout {
    _scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:_scrollView];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self.view];
}

- (void)layoutModules {
    for (int i = 0; i < self.modules.count; i++){
        UIView *moduleView = self.modules[i];
        
        [_scrollView addSubview:moduleView];
        moduleView.translatesAutoresizingMaskIntoConstraints = NO;
        [moduleView alignLeadingEdgeWithView:_scrollView predicate:@"0"];
        [moduleView alignTrailingEdgeWithView:_scrollView predicate:@"0"];
        [moduleView constrainHeight:[NSString stringWithFormat:@"%.f", moduleView.frame.size.height]];
        
        if(i == 0){
            [moduleView alignTopEdgeWithView:_scrollView predicate:@"0"];
            
            [moduleView alignLeadingEdgeWithView:self.view predicate:@"0"];
            [moduleView alignTrailingEdgeWithView:self.view predicate:@"0"];
        } else {
            UIView *topView = self.modules[i-1];
            [moduleView constrainTopSpaceToView:topView predicate:@"0"];
        }
    }
}

@end
