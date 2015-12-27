//
//  DBVenuesTableTableViewController.m
//  DoubleB
//
//  Created by Balaban Alexander on 31/07/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "DBVenuesTableViewController.h"
#import "OrderCoordinator.h"
#import "OrderManager.h"
#import "LocationHelper.h"
#import "Venue.h"
#import "DBVenueCell.h"
#import "DBVenueViewController.h"
#import "MBProgressHUD/MBProgressHUD.h"

#import "OrderManager.h"
#import "NetworkManager.h"

@interface DBVenuesTableViewController ()<DBVenueCellDelegate>

@property (nonatomic, strong) NSArray *venues;
@property (nonatomic, strong) UIPickerView *picker;

@end

@implementation DBVenuesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self db_setTitle:[DBTextResourcesHelper db_venuesTitleString]];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.picker = [UIPickerView new];
    
    self.tableView.rowHeight = 73;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    self.refreshControl = refreshControl;
    [refreshControl addTarget:self action:@selector(reloadVenues:) forControlEvents:UIControlEventValueChanged];
    
    self.venues = [Venue storedVenues];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateVenuesState) name:kDBConcurrentOperationFetchVenuesFinished object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [GANHelper analyzeScreen:@"Coffee_houses_screen"];
    [GANHelper analyzeEvent:@"all_venues_show" category:self.eventsCategory];

    [self reloadVenues:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadVenues:(UIRefreshControl *)refreshControl {
    [GANHelper analyzeEvent:@"venue_update" category:self.eventsCategory];

    if ([[LocationHelper sharedInstance] isDenied]) {
        [self fetchVenues:nil];
    } else {
        [[LocationHelper sharedInstance] updateLocationWithCallback:^(CLLocation *location) {
            [self fetchVenues:location];
        }];
    }
}

- (void)fetchVenues:(CLLocation *)location {
    if (location) {
        [[NetworkManager sharedManager] addPendingUniqueOperation:NetworkOperationFetchVenues withUserInfo:@{@"location": location}];
    } else {
        [[NetworkManager sharedManager] addPendingUniqueOperation:NetworkOperationFetchVenues];
    }
}

- (void)updateVenuesState {
    self.venues = [Venue storedVenues];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.venues count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBVenueCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBVenueCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DBVenueCell" owner:self options:nil] firstObject];
        cell.delegate = self;
    }
    
    [cell.venueDistanceLabel.layer setCornerRadius:5];
    
    Venue *venue = self.venues[indexPath.row];
    cell.venue = venue;
    double dist = venue.distance;
    if (dist && dist > 0) {
        [cell.venueDistanceLabel setBackgroundColor:[UIColor db_defaultColor]];
        if (dist > 1) {
            cell.venueDistanceLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%.1f км", nil), dist];
            if (dist > 3) {
                [cell.venueDistanceLabel setBackgroundColor:[UIColor fromHex:0xffa1aaaa]];
            }
        } else {
            cell.venueDistanceLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%.0f м", nil), dist * 1000];
        }
        cell.venueDistanceLabel.hidden = NO;
        cell.constraintDistanceLabelWidth.constant = 55;
        cell.constraintDistanceLabelAndVenueNameLabelSpace.constant = 10;
    } else {
        cell.venueDistanceLabel.hidden = YES;
        cell.constraintDistanceLabelWidth.constant = 0;
        cell.constraintDistanceLabelAndVenueNameLabelSpace.constant = 0;
    }
    cell.venueNameLabel.text = venue.title;
    cell.venueAddressLabel.text = venue.address;
    cell.venueWorkTimeLabel.text = venue.workingTime ?: NSLocalizedString(@"Пн-пт 8:00-20:00, сб-вс 11:00-18:00", nil);
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Venue *venue = _venues[indexPath.row];
    [OrderCoordinator sharedInstance].orderManager.venue = venue;
    [self.navigationController popViewControllerAnimated:YES];
    
    [GANHelper analyzeEvent:@"venue_click" label:venue.venueId category:self.eventsCategory];
}

#pragma mark - DBVenueCellDelegate

- (void)db_venueCellDidSelectInfo:(DBVenueCell *)cell {
    DBVenueViewController *controller = [DBVenueViewController new];
    controller.venue = cell.venue;
    
    [self.navigationController pushViewController:controller animated:YES];
    
    [GANHelper analyzeEvent:@"venue_info_click" label:cell.venue.venueId category:self.eventsCategory];
}

@end
