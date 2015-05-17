//
//  DBDeliveryViewController.m
//  DoubleB
//
//  Created by Dmitriy Stupivtsev on 05.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBAddressViewController.h"
#import "DBVenuesTableViewController.h"
#import "DBDeliveryViewController.h"
#import "UIViewController+NavigationBarFix.h"
#import "OrderManager.h"

@interface DBAddressViewController () <DBDeliveryViewControllerDataSource, DBVenuesTableViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *segmentsHolderView;
@property (weak, nonatomic) IBOutlet UIView *titleHolderView;
@property (weak, nonatomic) IBOutlet UIView *horizSeparatorView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) NSArray *controllers;
@end

@implementation DBAddressViewController
NSMutableArray *controllersInfo;

- (instancetype)initWithControllers:(NSArray *)controllers {
    self = [super init];
    if (self) {
        self.controllers = [NSArray arrayWithArray:controllers];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.segmentedControl.tintColor = [UIColor whiteColor];
    [self.segmentedControl addTarget:self
                              action:@selector(segmentedControlClick:)
                    forControlEvents:UIControlEventValueChanged];
    
    controllersInfo = [NSMutableArray new];
    
    for (UIViewController *controller in self.controllers) {
        if ([controller isKindOfClass:[DBVenuesTableViewController class]]) {
            /* Self-service */
            [controllersInfo addObject: @{@"name": @"Самовывоз", @"controller": controller, @"title": @"Точки самовывоза"}];
            ((DBVenuesTableViewController *)controller).delegate = self;
        } else if ([controller isKindOfClass:[DBDeliveryViewController class]]) {
            /* Delivery */
            [controllersInfo addObject: @{@"name": @"Доставка", @"controller": controller, @"title": @"Адрес доставки"}];
            [((DBDeliveryViewController *)controller) addToDataSource:self];
        }
    }
    
    [self.segmentedControl removeAllSegments];
    for (int i = 0; i < [_controllers count]; ++i) {
        [self.segmentedControl insertSegmentWithTitle:controllersInfo[i][@"name"] atIndex:i animated:NO];
    }
    self.segmentedControl.selectedSegmentIndex = 0;
    [self setContentForIndex:_segmentedControl.selectedSegmentIndex];
    
    self.segmentsHolderView.backgroundColor = [UIColor db_defaultColor];
    self.horizSeparatorView.backgroundColor = [UIColor db_defaultColor];
    self.titleHolderView.backgroundColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17.f];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.backgroundView.backgroundColor = [UIColor db_defaultColor];
    self.backgroundView.alpha = 0.885;
    [self hideNavigationBarShadow];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self showNavigationBarShadow];
}

- (void)segmentedControlClick:(UISegmentedControl *)segmentedControl {
    [self setContentForIndex:_segmentedControl.selectedSegmentIndex];
}

- (void)setContentForIndex:(NSUInteger)index {
    [self changeContentViewWithViewController:controllersInfo[index][@"controller"]];
    [self changeTitleLabelWithText:controllersInfo[index][@"title"]];
}

- (void)changeTitleLabelWithText:(NSString *)text {
    self.titleLabel.text = text;
}

#pragma mark - FIXME DEBUG VIEW HIERARHY
- (void)changeContentViewWithViewController:(UIViewController *)controller {
    controller.view.frame = CGRectMake(0, 0, _contentView.frame.size.width, _contentView.frame.size.height);
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    [self.contentView addSubview:controller.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - DBDeliveryViewControllerDataSource

- (UIView *)superView {
    return self.contentView;
}

#pragma mark - DBVenuesTableViewControllerDelegate

- (void)venuesController:(DBVenuesTableViewController *)controller didChooseVenue:(Venue *)venue {
    if(venue){
        [OrderManager sharedManager].venue = venue;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end