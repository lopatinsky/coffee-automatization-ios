//
//  DBInfiniteScrollView.m
//  DoubleB
//
//  Created by Dmitriy Stupivtsev on 01.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBInfiniteScrollView.h"

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define PAGES_AMOUNT 3

@interface DBInfiniteScrollView () <UIScrollViewDelegate>
@property (nonatomic, weak) id<DBInfiniteScrollViewDelegate> __delegate;
@property (nonatomic, weak) id<DBInfiniteScrollViewDataSource> __dataSource;

@property (nonatomic, readwrite) UIViewController *currentController;
@property (nonatomic, readwrite) UIViewController *nextController;
@property (nonatomic, readwrite) UIViewController *previousController;
@end

@implementation DBInfiniteScrollView

- (void)dealloc {
    self.previousController = nil;
    self.currentController = nil;
    self.nextController = nil;
}

- (void)addToDelegates:(id<DBInfiniteScrollViewDelegate>)__delegate {
    self.__delegate = __delegate;
}

- (void)addToDataSource:(id<DBInfiniteScrollViewDataSource>)__dataSource {
    self.__dataSource = __dataSource;
}

- (void)setControllers {
    [self createControllers];
    
    UIView *previousView = self.previousController.view;
    previousView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    UIView *currentView = self.currentController.view;
    currentView.frame = CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    UIView *nextView = self.nextController.view;
    nextView.frame = CGRectMake(SCREEN_WIDTH * 2, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    [self addSubview:previousView];
    [self addSubview:currentView];
    [self addSubview:nextView];
}

- (void)createControllers {
    self.currentController = [self currentViewController];
    self.nextController = [self nextViewController];
    self.previousController = [self previousViewController];
}

- (void)initScrollView {
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.pagingEnabled = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.scrollsToTop = NO;
    self.backgroundColor = [UIColor whiteColor];
    self.bounces = NO;    
    self.contentSize = CGSizeMake(SCREEN_WIDTH * PAGES_AMOUNT, SCREEN_HEIGHT);
    self.contentOffset = CGPointMake(SCREEN_WIDTH * (int)(PAGES_AMOUNT / 2), 0);
    
    super.delegate = self;
}

- (void)recenterIfNeededWithCompletionHandler:(void(^)(ScrollDirection direction))callback {
    CGPoint currentOffset = [self contentOffset];
    CGFloat contentWidth = [self contentSize].width;
    CGFloat centerOffsetX = (contentWidth - [self bounds].size.width) / 2.0;
    CGFloat offsetDelta = currentOffset.x - centerOffsetX;
    ScrollDirection dir;
    
    if (offsetDelta > 0) {
        dir = Left;
    } else if (offsetDelta < 0) {
        dir = Right;
    } else {
        dir = None;
    }
    
    CGFloat distanceFromCenter = fabs(offsetDelta);
    if ((int)(distanceFromCenter + SCREEN_WIDTH / 2) >= (int)(contentWidth / 2)) {
        self.contentOffset = CGPointMake(centerOffsetX, currentOffset.y);
        
        callback(dir);
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self recenterIfNeededWithCompletionHandler:^(ScrollDirection direction) {
        [self scrolledViewWithDirection: direction];
        [self setControllers];
    }];
}

#pragma mark - DBInfiniteScrollViewDelegate

- (void)scrolledViewWithDirection:(ScrollDirection)direction {
    [self.__delegate scrolledViewController:direction];
}

#pragma mark - DBInfiniteScrollViewDataSource

- (UIViewController *)currentViewController {
    return [self.__dataSource currentViewController];
}

- (UIViewController *)nextViewController {
    return [self.__dataSource nextViewController];
}

- (UIViewController *)previousViewController {
    return [self.__dataSource previousViewController];
}

@end
