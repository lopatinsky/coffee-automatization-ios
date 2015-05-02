//
//  DBInfiniteScrollView.h
//  DoubleB
//
//  Created by Dmitriy Stupivtsev on 01.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBPositionViewController.h"

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, ScrollDirection) {
    Left = 0,
    Right,
    None
};

@protocol DBInfiniteScrollViewDelegate <NSObject>
- (void)scrolledViewController:(ScrollDirection)direction;
//- (void)scrolledViewController:(UIViewController *)viewController;

@end

@protocol DBInfiniteScrollViewDataSource <NSObject>
- (UIViewController *)currentViewController;
- (UIViewController *)nextViewController;
- (UIViewController *)previousViewController;
@end

@interface DBInfiniteScrollView : UIScrollView
- (void)addToDelegates:(id<DBInfiniteScrollViewDelegate>)__delegate;
- (void)addToDataSource:(id<DBInfiniteScrollViewDataSource>)__dataSource;
- (void)initScrollView;
- (void)setControllers;
//- (instancetype)initWithViewController:(UIViewController *)viewController;

@property (nonatomic, readonly) UIViewController *currentController;
@property (nonatomic, readonly) UIViewController *nextController;
@property (nonatomic, readonly) UIViewController *previousController;
@end
