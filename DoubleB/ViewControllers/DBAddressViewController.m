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

#import "OrderManager.h"
#import "DBCompanyInfo.h"

#import "UIViewController+NavigationBarFix.h"

@interface DBAddressViewController () <DBDeliveryViewControllerDataSource>

@property (strong, nonatomic) IBOutlet UIView *placeholderView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet UILabel *deliveryTypeNameLabel;
@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (strong, nonatomic) IBOutlet UIView *fakeSeparatorView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fakeSeparatorHeightConstraint;

@property (strong, nonatomic) NSMutableDictionary *controllers;
@property (strong, nonatomic) NSArray *deliveryTypeNames;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *segmentHolderHeightConstraint;


@end

@implementation DBAddressViewController

#define DEBUG true

#pragma mark - Life-Cycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.controllers = [NSMutableDictionary new];
    
    [self initializeViews];
    [self initializeControllers];
    [self displayContentControllerWithTitle:self.deliveryTypeNames[0]];
}

- (void)viewWillAppear:(BOOL)animated {
    [self hideNavigationBarShadow];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self showNavigationBarShadow];
}

#pragma mark - Other methods
- (void)initializeViews {
    [self setTitle:@"Адрес"];
    self.placeholderView.backgroundColor = [UIColor db_defaultColor];
    self.placeholderView.alpha = 0.885;
    
    self.segmentedControl.tintColor = [UIColor whiteColor];
    self.segmentedControl.selectedSegmentIndex = 0;
    
    self.fakeSeparatorView.backgroundColor = [UIColor db_defaultColor];
    self.fakeSeparatorHeightConstraint.constant = 1. / [UIScreen mainScreen].scale;
}

- (void)initializeControllers {
    if ([[DBCompanyInfo sharedInstance] isDeliveryTypeEnabled:DeliveryTypeIdInRestaurant] ||
        [[DBCompanyInfo sharedInstance] isDeliveryTypeEnabled:DeliveryTypeIdTakeaway] || DEBUG) {
        DBVenuesTableViewController *newController = [DBVenuesTableViewController new];
        newController.delegate = self.delegate;
        self.controllers[@"Самовывоз"] = @{
                                            @"controller": newController,
                                            @"deliveryTypeName": @"Точки самовывоза"
                                           };
    }
    
    if ([[DBCompanyInfo sharedInstance] isDeliveryTypeEnabled:DeliveryTypeIdShipping] || DEBUG) {
        self.controllers[@"Доставка"] = @{
                                           @"controller": [DBDeliveryViewController new],
                                           @"deliveryTypeName": @"Адрес доставки"
                                           };
    }
    
    self.deliveryTypeNames = [self.controllers.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
    }];
    
    if ([self.deliveryTypeNames count] > 1) {
        [self.segmentedControl removeAllSegments];
        [self.deliveryTypeNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self.segmentedControl insertSegmentWithTitle:obj atIndex:idx animated:NO];
        }];
        
        self.segmentedControl.selectedSegmentIndex = 0;
    } else {
        self.segmentHolderHeightConstraint.constant = 0.0f;
        [self.view layoutIfNeeded];
    }
}

- (IBAction)deliveryTypeChanged:(id)sender {
    [self displayContentControllerWithTitle:self.deliveryTypeNames[self.segmentedControl.selectedSegmentIndex]];
}

- (void)displayContentControllerWithTitle:(NSString *)title {
    UIViewController *controller = self.controllers[title][@"controller"];
    self.deliveryTypeNameLabel.text = self.controllers[title][@"deliveryTypeName"];
    [self addChildViewController:controller];
    controller.view.frame = [self.contentView bounds];
    [self.contentView addSubview:controller.view];
    [controller didMoveToParentViewController:self];
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
