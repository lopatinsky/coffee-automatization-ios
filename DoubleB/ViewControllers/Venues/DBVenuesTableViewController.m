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
@end

@implementation DBVenuesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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

    [GANHelper analyzeScreen:self.eventsCategory];
    [GANHelper analyzeEvent:@"all_venues_show" category:self.eventsCategory];

    [self reloadVenues:nil];
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
    
    Venue *venue = [self.venues objectAtIndex:indexPath.row];
    [cell configure:venue];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Venue *venue = _venues[indexPath.row];
    
    if (_mode == DBVenuesViewControllerModeChooseVenue) {
        if ([OrderCoordinator sharedInstance].orderManager.venue != venue) {
            [[ApplicationManager sharedInstance] moveMenuToStartState:NO];
        }
        [OrderCoordinator sharedInstance].orderManager.venue = venue;
        [self.parentViewController.navigationController popViewControllerAnimated:YES];
    } else {
        DBVenueViewController *controller = [DBVenueViewController new];
        controller.venue = venue;
        [self.parentViewController.navigationController pushViewController:controller animated:YES];
    }
    
    [GANHelper analyzeEvent:@"venue_click" label:venue.venueId category:self.eventsCategory];
}

#pragma mark - DBVenueCellDelegate

- (void)db_venueCellDidSelectInfo:(DBVenueCell *)cell {
    DBVenueViewController *controller = [DBVenueViewController new];
    controller.venue = cell.venue;
    
    [self.parentViewController.navigationController pushViewController:controller animated:YES];
    
    [GANHelper analyzeEvent:@"venue_info_click" label:cell.venue.venueId category:self.eventsCategory];
}

@end
