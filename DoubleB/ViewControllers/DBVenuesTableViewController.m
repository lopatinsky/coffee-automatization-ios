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
#import "DBVenueViewController.h"
#import "MBProgressHUD/MBProgressHUD.h"
#import "OrderManager.h"
 
@interface DBVenuesTableViewController ()

@property (nonatomic, strong) UIPickerView *picker;

@end

@implementation DBVenuesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.picker = [UIPickerView new];
    
    self.navigationItem.title = NSLocalizedString(@"Кофейни", nil);
    
    self.tableView.rowHeight = 73;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    self.view.backgroundColor = [UIColor db_backgroundColor];
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    self.refreshControl = refreshControl;
    [refreshControl addTarget:self action:@selector(reloadVenues:) forControlEvents:UIControlEventValueChanged];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [GANHelper analyzeScreen:@"Coffee_houses_screen"];

    [self reloadVenues:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [GANHelper analyzeEvent:@"back_click" category:VENUES_SCREEN];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadVenues:(UIRefreshControl *)refreshControl {
    if ([self.venues count] && !refreshControl) {
        return;
    }
    [GANHelper analyzeEvent:@"update" category:VENUES_SCREEN];
    
    self.venues = [Venue storedVenues];

    /*if (!refreshControl) {
        [MBProgressHUD showHUDAddedTo:self.view animated:true];
    }*/
    if ([[LocationHelper sharedInstance] isDenied]) {
        [self fetchVenues:nil];
    } else {
        [[LocationHelper sharedInstance] updateLocationWithCallback:^(CLLocation *location) {
            [self fetchVenues:location];
        }];
    }
}

- (void)fetchVenues:(CLLocation *)location {
    NSDate *start = [NSDate date];
    void (^block)(NSArray *) = ^(NSArray *venues) {
        if (venues) {
            self.venues = venues;
            [self.tableView reloadData];
        }
        long interval = -(long)[start timeIntervalSinceNow];
        //[MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.refreshControl endRefreshing];
    };
    if (location) {
        [Venue fetchVenuesForLocation:location withCompletionHandler:block];
    } else {
        [Venue fetchAllVenuesWithCompletionHandler:block];
    }
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

    /*CGRect labelAddressFrame = cell.venueAddressLabel.frame;
    [cell.venueAddressLabel setFrame:CGRectMake(x, labelAddressFrame.origin.y, width, labelAddressFrame.size.height)];

    CGRect labelNameFrame = cell.venueNameLabel.frame;
    [cell.venueNameLabel setFrame:CGRectMake(x, labelNameFrame.origin.y, width, labelNameFrame.size.height)];
    CGRect labelWorkFrame = cell.venueWorkTimeLabel.frame;
    [cell.venueWorkTimeLabel setFrame:CGRectMake(x, labelWorkFrame.origin.y, width, labelWorkFrame.size.height)];*/
    cell.venueNameLabel.text = venue.title;
    cell.venueAddressLabel.text = venue.address;
    cell.venueWorkTimeLabel.text = venue.workingTime ?: NSLocalizedString(@"Пн-пт 8:00-20:00, сб-вс 11:00-18:00", nil);
    
    //cell.venueDistanceLabel.text = @"100 000 км";
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.delegate) {
        DBVenueViewController *controller = [DBVenueViewController new];
        Venue *venue = _venues[indexPath.row];
        controller.venue = venue;
        controller.hidesBottomBarWhenPushed = YES;
        [[LocationHelper sharedInstance] updateLocationWithCallback:^(CLLocation *location) {
            NSString *eventLabel = [NSString stringWithFormat:@"%@;%f;%f,%f",
                                    venue.venueId, venue.distance, location.coordinate.latitude, location.coordinate.longitude];
            [GANHelper analyzeEvent:@"venue_click" label:eventLabel category:VENUES_SCREEN];
        }];
        
        
        [self.navigationController pushViewController:controller animated:YES];
        return;
    }
    [self.delegate venuesController:self didChooseVenue:self.venues[indexPath.row]];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
