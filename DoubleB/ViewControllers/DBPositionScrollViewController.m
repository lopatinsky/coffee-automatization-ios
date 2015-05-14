//
//  DBInfiniteScrollViewController.m
//  DoubleB
//
//  Created by Dmitriy Stupivtsev on 30.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBPositionScrollViewController.h"
#import "DBPositionViewController.h"
#import "DBInfiniteScrollView.h"
#import "DBBarButtonItem.h"

#import "UINavigationController+DBAnimation.h"

@interface DBPositionScrollViewController () <UIScrollViewDelegate ,DBInfiniteScrollViewDelegate, DBInfiniteScrollViewDataSource>
@property (strong, nonatomic) NSMutableArray *positions;
@property (weak, nonatomic) DBMenuPosition *position;

@property (strong, nonatomic) DBInfiniteScrollView *scrollView;
@property (nonatomic, assign) CGFloat *currentContentOffset;
@end

@implementation DBPositionScrollViewController

- (instancetype)initWithPosition:(DBMenuPosition *)position categories:(NSArray *)categories {
    self = [super init];
    
    self.positions = [NSMutableArray new];
    for (DBMenuCategory *category in categories) {
        [self.positions addObjectsFromArray:category.positions];
    }
    
    self.position = position;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView = [DBInfiniteScrollView new];
    [self.scrollView addToDataSource:self];
    [self.scrollView addToDelegates:self];
    [self.scrollView initScrollView];
    [self.scrollView setControllers];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.view addSubview:_scrollView];
    
    self.navigationItem.rightBarButtonItem = [[DBBarButtonItem alloc] initWithViewController:self action:@selector(goToOrderViewController)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (DBMenuPosition *)nextPosition {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"positionId == %@", self.position.positionId];
    NSUInteger index = [_positions indexOfObject:[[self.positions filteredArrayUsingPredicate:predicate] firstObject]];
    if (index < [_positions count] - 1) {
        ++index;
    } else if (index == [_positions count] - 1) {
        index = 0;
    }
    
    if (index == NSNotFound || index >= [_positions count]) {
        return NULL;
    }
    
    return [_positions objectAtIndex:index];
}

- (DBMenuPosition *)previousPosition {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"positionId == %@", self.position.positionId];
    NSUInteger index = [_positions indexOfObject:[[self.positions filteredArrayUsingPredicate:predicate] firstObject]];
    if (index > 0) {
        --index;
    } else if (index == 0) {
        index = [_positions count] - 1;
    }
    
    if (index == NSNotFound || index >= [_positions count]) {
        return NULL;
    }
    
    return [_positions objectAtIndex:index];
}

- (void)goToOrderViewController{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [GANHelper analyzeEvent:@"back_arrow_pressed" category:PRODUCT_SCREEN];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - DBInfiniteScrollViewControllerDelegate

- (void)scrolledViewController:(ScrollDirection)direction {
    switch (direction) {
        case Left:
            self.position = [self nextPosition];
            break;
        case Right:
            self.position = [self previousPosition];
            break;
        case None:
            break;
    }
}

- (void)didSetViewWithController:(UIViewController *)controller {
//    [self addChildViewController:controller];
//    NSLog(@"child controllers count: %d", [[self childViewControllers] count]);
//    if ([[self childViewControllers] count] > 3) {
//        [[[self childViewControllers] firstObject] removeFromParentViewController];
//    }
}

#pragma mark - DBInfiniteScrollViewControllerDataSource

- (UIViewController *)currentViewController {
    DBPositionViewController *positionVC = [[DBPositionViewController alloc] initWithPosition:_position
                                                                                         mode:DBPositionViewControllerModeMenuPosition
                                                                         navigationController:self.navigationController];
    NSLog(@"current position name: %@ VC: %@", _position.name, positionVC);
    return positionVC;
}

- (UIViewController *)nextViewController {
    DBPositionViewController *positionVC = [[DBPositionViewController alloc] initWithPosition:[self nextPosition]
                                                                                         mode:DBPositionViewControllerModeMenuPosition
                                                                         navigationController:self.navigationController];
    NSLog(@"next position name: %@ VC: %@", [self nextPosition].name, positionVC);
    return positionVC;
}

- (UIViewController *)previousViewController {
    DBPositionViewController *positionVC = [[DBPositionViewController alloc] initWithPosition:[self previousPosition]
                                                                                         mode:DBPositionViewControllerModeMenuPosition
                                                                         navigationController:self.navigationController];
    NSLog(@"previous position name: %@ VC: %@", [self previousPosition].name, positionVC);
    return positionVC;
}

@end
