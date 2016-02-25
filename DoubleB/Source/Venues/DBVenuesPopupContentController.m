//
//  DBVenuesPopupContentController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 25/02/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBVenuesPopupContentController.h"
#import "DBVenuesTableViewController.h"
#import "DBVenuesMapViewController.h"

#import "DBVenuesViewController.h"

#import "OrderCoordinator.h"
#import "OrderManager.h"

@interface DBVenuesPopupContentController ()<DBVenuesControllerContainerDelegate>
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIView *confirmationView;
@property (weak, nonatomic) IBOutlet UILabel *confirmationLabel;
@property (weak, nonatomic) IBOutlet UISwitch *confirmationSwitch;

@property (strong, nonatomic) DBVenuesTableViewController *venuesTableVC;
@property (strong, nonatomic) DBVenuesMapViewController *venuesMapVC;

@property (strong, nonatomic) UIButton *rightNavButton;

@end

@implementation DBVenuesPopupContentController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.titleLabel.text = NSLocalizedString(@"Выберите ресторан для заказа", nil);
    
    self.venuesTableVC = [DBVenuesTableViewController new];
    self.venuesTableVC.eventsCategory = self.eventsCategory;
    self.venuesTableVC.delegate = self;
    [self addChildViewController:self.venuesTableVC];
    [self.contentView addSubview:self.venuesTableVC.view];
    self.venuesTableVC.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.venuesTableVC.view alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self.contentView];
    
    self.venuesMapVC = [DBVenuesMapViewController new];
    self.venuesMapVC.eventsCategory = self.eventsCategory;
    self.venuesMapVC.delegate = self;
    [self addChildViewController:self.venuesMapVC];
    [self.contentView addSubview:self.venuesMapVC.view];
    self.venuesMapVC.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.venuesMapVC.view alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self.contentView];
    self.venuesMapVC.view.hidden = YES;
}

- (UIView *)db_popupContentRightNavigationItem {
    _rightNavButton = [UIButton new];
    _rightNavButton.frame = CGRectMake(0, 0, 70, 35);
    [_rightNavButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [_rightNavButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _rightNavButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    [_rightNavButton setTitle:NSLocalizedString(@"Карта", nil) forState:UIControlStateNormal];
    
    [_rightNavButton addTarget:self action:@selector(clickBarButton) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *view = [[UIView alloc] initWithFrame:_rightNavButton.frame];
    [view addSubview:_rightNavButton];
    view.backgroundColor = [UIColor clearColor];
    
    return view;
}

- (void)clickBarButton {
    self.venuesTableVC.view.hidden = !self.venuesTableVC.view.hidden;
    self.venuesMapVC.view.hidden = !self.venuesMapVC.view.hidden;
    
    if (self.venuesTableVC.view.hidden) {
        [_rightNavButton setTitle:NSLocalizedString(@"Список", nil) forState:UIControlStateNormal];
        [self.venuesMapVC update];
    } else {
        [_rightNavButton setTitle:NSLocalizedString(@"Карта", nil) forState:UIControlStateNormal];
    }
}

#pragma mark - DBVenuesControllerContentDelegate

- (BOOL)db_venuesControllerContentSelectEnabled {
    return YES;
}

- (BOOL)db_venuesControllerContentSelectInfoEnabled {
    return NO;
}

- (void)db_venuesControllerContentDidSelectVenue:(Venue *)venue {
    if ([OrderCoordinator sharedInstance].orderManager.venue != venue) {
        [[ApplicationManager sharedInstance] moveMenuToStartState:NO];
    }
    [OrderCoordinator sharedInstance].orderManager.venue = venue;
    [self.popupViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)db_venuesControllerContentDidSelectVenueInfo:(Venue *)venue {
}

//#pragma mark - DBSettingsProtocol
//
//+ (DBSettingsItem *)settingsItemForViewController:(UIViewController *)viewController {
//    DBSettingsItem *settingsItem = [DBSettingsItem new];
//    settingsItem.name = @"venuesVC";
//    settingsItem.title = [DBTextResourcesHelper db_venuesTitleString];
//    settingsItem.iconName = @"map_icon_active";
//    settingsItem.viewController = viewController;
//    settingsItem.eventLabel = @"venues_click";
//    settingsItem.navigationType = DBSettingsItemNavigationPush;
//    return settingsItem;
//}
//
//+ (id<DBSettingsItemProtocol>)settingsItem {
//    DBVenuesViewController *venuesVC = [DBVenuesViewController new];
//    venuesVC.mode = DBVenuesViewControllerModeList;
//    return [DBVenuesViewController settingsItemForViewController:venuesVC];
//}


@end
