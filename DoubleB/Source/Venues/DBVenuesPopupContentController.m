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
#import "DBVenueStartSelectionSettingsView.h"
#import "DBPopupViewController.h"

#import "OrderCoordinator.h"
#import "OrderManager.h"

@interface DBVenuesPopupContentController ()<DBVenuesControllerContainerDelegate>
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIView *confirmationViewHolder;

@property (strong, nonatomic) DBVenuesTableViewController *venuesTableVC;
@property (strong, nonatomic) DBVenuesMapViewController *venuesMapVC;

@property (strong, nonatomic) DBVenueStartSelectionSettingsView *confirmationView;

@property (strong, nonatomic) UIButton *rightNavButton;

@end

@implementation DBVenuesPopupContentController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor db_backgroundColor];

    self.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Выберите %@ для заказа", nil), [DBTextResourcesHelper db_venueTitleString:4].lowercaseString];
    
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
    
    self.confirmationView = [DBVenueStartSelectionSettingsView create];
    self.confirmationView.backgroundColor = [UIColor db_backgroundColor];
    self.confirmationView.title = NSLocalizedString(@"Запомнить мой выбор", nil);
    [self.confirmationViewHolder addSubview:self.confirmationView];
    self.confirmationView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.confirmationView alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self.confirmationViewHolder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.venuesTableVC beginAppearanceTransition:YES animated:YES];
    [self.venuesMapVC beginAppearanceTransition:YES animated:YES];
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

- (BOOL)db_venuesControllerContentSelectEnabled:(NSObject *)sender {
    return YES;
}

- (BOOL)db_venuesControllerContentSelectInfoEnabled:(NSObject *)sender {
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

#pragma mark - DBSettingsProtocol

+ (id<DBSettingsItemProtocol>)settingsItem {
    DBSettingsItem *settingsItem = [DBSettingsItem new];
    settingsItem.name = @"venuesPopupSettingsVC";
    settingsItem.title = [NSString stringWithFormat:NSLocalizedString(@"Запоминать выбор %@", nil), [DBTextResourcesHelper db_venueTitleString:2].lowercaseString];
    settingsItem.iconName = @"map_icon_active";
    settingsItem.eventLabel = @"venues_popup_settings_click";
    
    DBVenueStartSelectionSettingsView *view = [DBVenueStartSelectionSettingsView create];
    view.title = [NSString stringWithFormat:NSLocalizedString(@"Запоминать %@ и не показывать всплывающее окно при запуске приложения", nil), [DBTextResourcesHelper db_venueTitleString:4].lowercaseString];
    settingsItem.block = ^(UIViewController *vc){
        [DBPopupViewController presentView:view inContainer:vc mode:DBPopupVCAppearanceModeHeader];
    };
    
    return settingsItem;
}


@end
