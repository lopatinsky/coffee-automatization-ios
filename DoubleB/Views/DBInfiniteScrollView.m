//
//  DBInfiniteScrollView.m
//  DoubleB
//
//  Created by Dmitriy Stupivtsev on 01.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBInfiniteScrollView.h"

#define PAGES_AMOUNT 3


typedef NS_ENUM(NSUInteger, ViewPosition) {
    Previous = 0,
    Current,
    Next
};

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
    
    [self setViewWithController:_previousController withPosition:Previous];
    [self setViewWithController:_currentController withPosition:Current];
    [self setViewWithController:_nextController withPosition:Next];
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

- (void)setViewWithController:(UIViewController *)controller withPosition:(ViewPosition)position {
    switch (position) {
        case Previous:
            controller.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            break;
        case Current:
            controller.view.frame = CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            break;
        case Next:
            controller.view.frame = CGRectMake(SCREEN_WIDTH * 2, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            break;
    }
    [self addSubview:controller.view];
    [self.__delegate didSetViewWithController:controller];
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
