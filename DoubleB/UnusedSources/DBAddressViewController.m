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

#import "OrderCoordinator.h"
#import "DeliverySettings.h"
#import "OrderManager.h"
#import "DBCompanyInfo.h"

#import "UIViewController+NavigationBarFix.h"

// TODO: check event category for venues table view controller
// TODO: chech delivery_type_selected event

@interface DBAddressViewController ()

@property (strong, nonatomic) IBOutlet UIView *placeholderView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *segmentHolderHeightConstraint;

@property (strong, nonatomic) OrderCoordinator *orderCoordinator;

@property (strong, nonatomic) NSMutableDictionary *controllers;
@property (strong, nonatomic) NSArray *deliveryTypeNames;

@end

@implementation DBAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.orderCoordinator = [OrderCoordinator sharedInstance];
    
    self.controllers = [NSMutableDictionary new];
    [self initializeViews];
    [self initializeControllers];
    
    if ([self.deliveryTypeNames count] > 1) {
        if (_orderCoordinator.deliverySettings.deliveryType.typeId == DeliveryTypeIdShipping) {
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
    } else if ([self.deliveryTypeNames count]) {
        [self displayContentControllerWithTitle:self.deliveryTypeNames[0]];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self hideNavigationBarShadow];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self showNavigationBarShadow];
    
    if ([[_orderCoordinator.deliverySettings deliveryType] typeId] == DeliveryTypeIdShipping) {
        [GANHelper analyzeEvent:@"back_pressed" category:ADDRESS_SCREEN];
    } else {
        [GANHelper analyzeEvent:@"back_click" category:VENUES_SCREEN];
    }
}

#pragma mark - Other methods
- (void)initializeViews {
    if (CGColorEqualToColor([UIColor db_defaultColor].CGColor, [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0].CGColor)) {
        self.placeholderView.backgroundColor = [UIColor whiteColor];
        self.segmentedControl.tintColor = [UIColor db_defaultColor];
        
    } else {
        self.placeholderView.backgroundColor = [UIColor db_defaultColor];
        self.placeholderView.alpha = 0.885;
        
        self.segmentedControl.tintColor = [UIColor whiteColor];
    }
    self.segmentedControl.selectedSegmentIndex = 0;
    
}

- (void)initializeControllers {
    if ([[DBCompanyInfo sharedInstance] isDeliveryTypeEnabled:DeliveryTypeIdInRestaurant] ||
        [[DBCompanyInfo sharedInstance] isDeliveryTypeEnabled:DeliveryTypeIdTakeaway]) {
        DBVenuesTableViewController *venuesVC = [DBVenuesTableViewController new];
        venuesVC.mode = DBVenuesTableViewControllerModeChooseVenue;
        venuesVC.eventsCategory = VENUES_ORDER_SCREEN;
        self.controllers[@"Самовывоз"] = @{@"controller": venuesVC,
                                           @"deliveryTypeName": NSLocalizedString(@"Заведения", nil)};
    }
    
    if ([[DBCompanyInfo sharedInstance] isDeliveryTypeEnabled:DeliveryTypeIdShipping]) {
        DBDeliveryViewController *deliveryViewController = [DBDeliveryViewController new];
        deliveryViewController.delegate = self;
        self.controllers[@"Доставка"] = @{@"controller": deliveryViewController,
                                          @"deliveryTypeName": NSLocalizedString(@"Адрес доставки", nil)};
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
        self.placeholderView.hidden = YES;
        NSMutableArray *placeholderConstraints = [NSMutableArray arrayWithArray:self.placeholderView.constraints];
        [placeholderConstraints removeObject:self.segmentHolderHeightConstraint];
        [self.placeholderView removeConstraints:placeholderConstraints];
        self.segmentHolderHeightConstraint.constant = 0.0f;
        [self.view layoutIfNeeded];
    }
}

- (IBAction)deliveryTypeChanged:(id)sender {
    if ([self.deliveryTypeNames[self.segmentedControl.selectedSegmentIndex] isEqualToString:@"Самовывоз"]) {
        [_orderCoordinator.deliverySettings selectTakeout];
        [GANHelper analyzeEvent:@"takeaway_selected" category:ORDER_SCREEN];
    }
    if ([self.deliveryTypeNames[self.segmentedControl.selectedSegmentIndex] isEqualToString:@"Доставка"]) {
        [_orderCoordinator.deliverySettings selectShipping];
        [GANHelper analyzeEvent:@"shipping_selected" category:ORDER_SCREEN];
    }
    [self displayContentControllerWithTitle:self.deliveryTypeNames[self.segmentedControl.selectedSegmentIndex]];
}

- (void)displayContentControllerWithTitle:(NSString *)title {
    if ([title isEqualToString:@"Самовывоз"]) {
        [_orderCoordinator.deliverySettings selectTakeout];
    }
    if ([title isEqualToString:@"Доставка"]) {
        [_orderCoordinator.deliverySettings selectShipping];
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
        _orderCoordinator.orderManager.venue = venue;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
