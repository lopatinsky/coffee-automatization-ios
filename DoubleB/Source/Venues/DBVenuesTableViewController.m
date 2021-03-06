//
//  DBVenuesTableTableViewController.m
//  DoubleB
//
//  Created by Balaban Alexander on 31/07/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "DBVenuesTableViewController.h"
#import "LocationHelper.h"
#import "Venue.h"
#import "DBVenueCell.h"
#import "MBProgressHUD/MBProgressHUD.h"

#import "OrderManager.h"
#import "NetworkManager.h"

@interface DBVenuesTableViewController ()<DBVenueCellDelegate>
@property (nonatomic, strong) NSArray *venues;
@property (strong, nonatomic) CLLocation *userLocation;
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
    
    [self reload];
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

    if (![[LocationHelper sharedInstance] isDenied]) {
        [[LocationHelper sharedInstance] updateLocationWithCallback:^(CLLocation *location) {
            _userLocation = location;
            [self reload];
            
            [Venue fetchVenuesForLocation:nil withCompletionHandler:^(NSArray *venues) {
                [self reload];
                [self.refreshControl endRefreshing];
            }];
        }];
    }
}

- (void)reload {
    NSMutableArray *mutVenues = [NSMutableArray arrayWithArray:[Venue storedVenues]];
    for (Venue *venue in mutVenues) {
        venue.distance = [_userLocation distanceFromLocation:[[CLLocation alloc] initWithLatitude:venue.latitude longitude:venue.longitude]] / 1000;
    }
    
    [mutVenues sortUsingComparator:^NSComparisonResult(Venue  *obj1, Venue *obj2) {
        return [@(obj1.distance) compare:@(obj2.distance)];
    }];
    
    self.venues = mutVenues;
    [self.tableView reloadData];
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
    
    cell.infoButtonEnabled = [self.delegate db_venuesControllerContentSelectInfoEnabled:self];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Venue *venue = _venues[indexPath.row];
    
    if ([self.delegate db_venuesControllerContentSelectEnabled:self]) {
        [self.delegate db_venuesControllerContentDidSelectVenue:venue];
    }
    
    [GANHelper analyzeEvent:@"venue_click" label:venue.venueId category:self.eventsCategory];
}

#pragma mark - DBVenueCellDelegate

- (void)db_venueCellDidSelectInfo:(DBVenueCell *)cell {
    [self.delegate db_venuesControllerContentDidSelectVenueInfo:cell.venue];
    
    [GANHelper analyzeEvent:@"venue_info_click" label:cell.venue.venueId category:self.eventsCategory];
}

@end
