//
//  DBVenuesViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 14/01/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBVenuesViewController.h"
#import "DBVenuesTableViewController.h"
#import "DBVenuesMapViewController.h"

@interface DBVenuesViewController ()
@property (strong, nonatomic) DBVenuesTableViewController *venuesTableVC;
@property (strong, nonatomic) DBVenuesMapViewController *venuesMapVC;
@end

@implementation DBVenuesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self db_setTitle:[DBTextResourcesHelper db_venuesTitleString]];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self setupBarButton];
    
    self.venuesTableVC = [DBVenuesTableViewController new];
    self.venuesTableVC.eventsCategory = self.eventsCategory;
    self.venuesTableVC.mode = self.mode;
    [self addChildViewController:self.venuesTableVC];
    [self.view addSubview:self.venuesTableVC.view];
    self.venuesTableVC.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.venuesTableVC.view alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self.view];
    
    self.venuesMapVC = [DBVenuesMapViewController new];
    self.venuesMapVC.eventsCategory = self.eventsCategory;
    self.venuesMapVC.mode = self.mode;
    [self addChildViewController:self.venuesMapVC];
    [self.view addSubview:self.venuesMapVC.view];
    self.venuesMapVC.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.venuesMapVC.view alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self.view];
    self.venuesMapVC.view.hidden = YES;
}

- (void)setupBarButton {
    UIButton *button = [UIButton new];
    button.frame = CGRectMake(0, 0, 70, 35);
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    button.contentEdgeInsets = UIEdgeInsetsMake(3, 0, 0, 0);
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    [button setTitle:NSLocalizedString(@"Карта", nil) forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(clickBarButton) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)clickBarButton {
    self.venuesTableVC.view.hidden = !self.venuesTableVC.view.hidden;
    self.venuesMapVC.view.hidden = !self.venuesMapVC.view.hidden;
    
    UIButton *button = self.navigationItem.rightBarButtonItem.customView;
    if (self.venuesTableVC.view.hidden) {
        [button setTitle:NSLocalizedString(@"Список", nil) forState:UIControlStateNormal];
        [self.venuesMapVC update];
    } else {
        [button setTitle:NSLocalizedString(@"Карта", nil) forState:UIControlStateNormal];
    }
}


@end
