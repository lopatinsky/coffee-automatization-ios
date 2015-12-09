//
//  DBPreviewViewController.m
//  DoubleB
//
//  Created by Ощепков Иван on 18.02.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBPreviewViewController.h"
#import "DBPreviewItemViewController.h"
#import "UIViewController+DBCardManagement.h"
#import "UIColor+Hex.h"
#import "DBTabBarController.h"
#import "AppDelegate.h"
#import "CAGradientLayer+Helper.h"

@interface DBPreviewViewController ()<UIScrollViewDelegate, DBPreviewItemDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *previewScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *previewPageControl;
@property (strong, nonatomic) NSArray *previewControllers;
@property (strong, nonatomic) NSArray *previewSources;

@end

@implementation DBPreviewViewController {
    CAGradientLayer *_gradientLayer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor db_blueColor];
    
    self.previewSources = @[@"preview_1.png", @"preview_2.png", @"preview_3.png", @"preview_4.png", @"preview_5.png"];
    
    self.previewScrollView.delegate = self;
    self.previewScrollView.backgroundColor = [UIColor clearColor];
    
    self.previewPageControl.numberOfPages = [self.previewSources count];
    self.previewPageControl.currentPage = 0;
    
    [self configurePreviewItems];
}

- (void)configurePreviewItems {
    NSMutableArray *viewControllers = [NSMutableArray array];
    NSMutableArray *views = [NSMutableArray array];
    for (int i = 0; i < [self.previewSources count]; i++){
        DBPreviewItemViewController *previewItemVC = [[DBPreviewItemViewController alloc] initWithImage:[UIImage imageNamed:self.previewSources[i]] final:(i == [self.previewSources count] - 1)];
        previewItemVC.delegate = self;
        
        [self.previewScrollView addSubview:previewItemVC.view];
        [viewControllers addObject:previewItemVC];
        [views addObject:previewItemVC.view];
        
        //autolayout
        [previewItemVC.view alignTop:@"0" bottom:@"0" toView:self.previewScrollView];
        [previewItemVC.view constrainHeightToView:self.view predicate:@"0"];
        [previewItemVC.view constrainWidthToView:self.view predicate:@"0"];
    }
    self.previewControllers = viewControllers;
    
    [UIView spaceOutViewsHorizontally:views predicate:@"0"];
    [[views firstObject] alignLeadingEdgeWithView:self.previewScrollView predicate:@"0"];
    [[views lastObject] alignTrailingEdgeWithView:self.previewScrollView predicate:@"0"];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    int page = self.previewScrollView.contentOffset.x/scrollView.frame.size.width;
    self.previewPageControl.currentPage = page;
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = self.view.bounds;
        _gradientLayer.colors = @[(id)[UIColor fromHex:0xffafe7e7].CGColor, (id)[UIColor fromHex:0xff53cfcd].CGColor];
        _gradientLayer.startPoint = CGPointMake(0.5, 0.0);
        _gradientLayer.endPoint = CGPointMake(0.5, 1.0);
        [self.view.layer insertSublayer:_gradientLayer atIndex:0];
    }
}

#pragma mark - DBPreviewItemDelegate

- (void)db_previewItemDidChooseBindCard:(DBPreviewItemViewController *)previewItemViewController{
    [self db_cardManagementBindNewCardOnScreen:@"Preview_screen" callback:^(BOOL success) {
        if(success){
            [UIView transitionWithView:[(AppDelegate *)[[UIApplication sharedApplication] delegate] window]
                              duration:0.5
                               options:UIViewAnimationOptionTransitionFlipFromLeft
                            animations:^{
                                [(AppDelegate *)[[UIApplication sharedApplication] delegate] window].rootViewController = [DBTabBarController sharedInstance];
                            }
                            completion:nil];
        }
    }];
}

- (void)db_previewItemDidChooseSkipBinding:(DBPreviewItemViewController *)previewItemViewController{
    [UIView transitionWithView:[(AppDelegate *)[[UIApplication sharedApplication] delegate] window]
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        [(AppDelegate *)[[UIApplication sharedApplication] delegate] window].rootViewController = [DBTabBarController sharedInstance];
                    }
                    completion:nil];
}


@end
