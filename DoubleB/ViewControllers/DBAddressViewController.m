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

@interface DBAddressViewController ()

@property (strong, nonatomic) IBOutlet UIView *placeholderView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (strong, nonatomic) NSMutableDictionary *controllers;
@property (strong, nonatomic) NSArray *deliveryTypeNames;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *segmentHolderHeightConstraint;

@end

@implementation DBAddressViewController

#pragma mark - Life-Cycle methods

- (instancetype)initWithDelegate:(id<DBVenuesTableViewControllerDelegate> __nonnull)delegate {
    self = [DBAddressViewController new];
    self.delegate = delegate;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.controllers = [NSMutableDictionary new];
    [self initializeViews];
    [self initializeControllers];
    
    if ([self.deliveryTypeNames count] > 1) {
        if ([DBDeliverySettings sharedInstance].deliveryType.typeId == DeliveryTypeIdShipping) {
            if ([[self.segmentedControl titleForSegmentAtIndex:0] isEqualToString:@"Доставка"]) {
                [self displayContentControllerWithTitle:self.deliveryTypeNames[0]];
                self.segmentedControl.selectedSegmentIndex = 0;
            } else {
                [self displayContentControllerWithTitle:self.deliveryTypeNames[1]];
                self.segmentedControl.selectedSegmentIndex = 1;
            }
        } else {
            if ([[self.segmentedControl titleForSegmentAtIndex:0] isEqualToString:@"Доставка"]) {
                [self displayContentControllerWithTitle:self.deliveryTypeNames[1]];
                self.segmentedControl.selectedSegmentIndex = 1;
            } else {
                [self displayContentControllerWithTitle:self.deliveryTypeNames[0]];
                self.segmentedControl.selectedSegmentIndex = 0;
            }
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self hideNavigationBarShadow];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self showNavigationBarShadow];
}

#pragma mark - Other methods
- (void)initializeViews {
    self.placeholderView.backgroundColor = [UIColor db_defaultColor];
    self.placeholderView.alpha = 0.885;
    
    self.segmentedControl.tintColor = [UIColor whiteColor];
    self.segmentedControl.selectedSegmentIndex = 0;
}

- (void)initializeControllers {
    if ([[DBCompanyInfo sharedInstance] isDeliveryTypeEnabled:DeliveryTypeIdInRestaurant] ||
        [[DBCompanyInfo sharedInstance] isDeliveryTypeEnabled:DeliveryTypeIdTakeaway]) {
        DBVenuesTableViewController *newController = [DBVenuesTableViewController new];
        newController.delegate = self.delegate;
        self.controllers[@"Самовывоз"] = @{
                                            @"controller": newController,
                                            @"deliveryTypeName": NSLocalizedString(@"Точки самовывоза", nil)
                                           };
    }
    
    if ([[DBCompanyInfo sharedInstance] isDeliveryTypeEnabled:DeliveryTypeIdShipping]) {
        DBDeliveryViewController *deliveryViewController = [DBDeliveryViewController new];
        deliveryViewController.delegate = self;
        self.controllers[@"Доставка"] = @{
                                           @"controller": deliveryViewController,
                                           @"deliveryTypeName": NSLocalizedString(@"Адрес доставки", nil)
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
    if ([self.deliveryTypeNames[self.segmentedControl.selectedSegmentIndex] isEqualToString:@"Самовывоз"]) {
        [[DBDeliverySettings sharedInstance] selectTakeout];
    }
    if ([self.deliveryTypeNames[self.segmentedControl.selectedSegmentIndex] isEqualToString:@"Доставка"]) {
        [[DBDeliverySettings sharedInstance] selectShipping];
    }
    [self displayContentControllerWithTitle:self.deliveryTypeNames[self.segmentedControl.selectedSegmentIndex]];
}

- (void)displayContentControllerWithTitle:(NSString *)title {
    if ([title isEqualToString:@"Самовывоз"]) {
        [[DBDeliverySettings sharedInstance] selectTakeout];
    }
    if ([title isEqualToString:@"Доставка"]) {
        [[DBDeliverySettings sharedInstance] selectShipping];
    }
    
    UIViewController *controller = self.controllers[title][@"controller"];
    [self setTitle:self.controllers[title][@"deliveryTypeName"]];
    [self addChildViewController:controller];
    controller.view.frame = [self.contentView bounds];
    [self.contentView addSubview:controller.view];
    [controller didMoveToParentViewController:self];
}

#pragma mark - KeyboardAppearance protocol FIX IT
- (void)keyboardWillAppear {
    self.segmentedControl.userInteractionEnabled = NO;
}

- (void)keyboardWillDisappear {
    self.segmentedControl.userInteractionEnabled = YES;
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
