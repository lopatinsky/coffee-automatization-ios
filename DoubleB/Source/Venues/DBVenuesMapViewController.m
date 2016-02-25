//
//  DBVenuesMapViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 13/01/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBVenuesMapViewController.h"
#import "Venue.h"
#import "NetworkManager.h"
#import "DBVenueInfoView.h"
#import "LocationHelper.h"
#import "DBVenueViewController.h"

#import <GoogleMaps/GoogleMaps.h>

@interface DBVenuesMapViewController ()<GMSMapViewDelegate, DBVenueInfoViewDelegate>
@property (nonatomic, strong) NSArray *venues;

@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) DBVenueInfoView *venueInfoView;

@property (nonatomic) BOOL setupCamera;
@end

@implementation DBVenuesMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.venues = [Venue storedVenues];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateVenuesState) name:kDBConcurrentOperationFetchVenuesFinished object:nil];
    
    self.venueInfoView = [DBVenueInfoView create];
    self.venueInfoView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [GANHelper analyzeScreen:self.eventsCategory];
    [GANHelper analyzeEvent:@"all_venues_show" category:self.eventsCategory];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.mapView) {
        self.mapView = [GMSMapView new];
        self.mapView.delegate = self;
        self.mapView.myLocationEnabled = YES;
        
        [self.view addSubview:self.mapView];
        self.mapView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.mapView alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self.view];
        
        [self reloadMarkers];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)update {
    if (!_setupCamera) {
        [self setupCamera];
        _setupCamera = YES;
    }
}

- (void)updateVenuesState {
    self.venues = [Venue storedVenues];
    [self reloadMarkers];
}

- (void)reloadMarkers {
    [self.mapView clear];
    
    for (Venue *venue in self.venues) {
        GMSMarker *marker = [GMSMarker markerWithPosition:venue.location];
        marker.icon = [UIImage imageNamed:@"map_icon_active.png"];
        marker.map = self.mapView;
        marker.userData = venue;
    }
}

#pragma mark - Map Camera Settings

- (BOOL)setupCamera {
    void (^cameraForLocation)(CLLocation *) = ^void(CLLocation *location) {
        NSArray *venues = [self venuesInRadius:3000 of:location];
        if (venues.count > 0) {
            GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:location.coordinate coordinate:((Venue*)venues.firstObject).location];
            for (int i = 2; i < venues.count; i++) {
                bounds = [bounds includingCoordinate:((Venue*)self.venues[i]).location];
            }
            [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds]];
        } else {
            [self.mapView setCamera:[GMSCameraPosition cameraWithLatitude:location.coordinate.latitude
                                                                longitude:location.coordinate.longitude
                                                                     zoom:14]];
        }
    };
    
    if (self.mapView.myLocation) { // Map View save user location, camera bounces by user location and venues
        cameraForLocation(self.mapView.myLocation);
    } else {
        if (self.venues.count > 1) { // Camera bounces by venues
            GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:((Venue*)self.venues[0]).location coordinate:((Venue*)self.venues[1]).location];
            for (int i = 2; i < self.venues.count; i++) {
                bounds = [bounds includingCoordinate:((Venue*)self.venues[i]).location];
            }
            [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds]];
        } else { // Camera on one venue
            Venue *venue = self.venues.firstObject;
            [self.mapView setCamera:[GMSCameraPosition cameraWithLatitude:venue.location.latitude
                                                                longitude:venue.location.longitude
                                                                     zoom:14]];
        }
        
        // Try to update user location and move camera
        [[LocationHelper sharedInstance] updateLocationWithCallback:^(CLLocation *location) {
            cameraForLocation(location);
        }];
    }
    
    return YES;
}

- (NSArray *)venuesInRadius:(double)rad of:(CLLocation *)location{
    NSMutableArray *resultVenues = [NSMutableArray new];
    for (Venue *venue in _venues) {
        if ([location distanceFromLocation:[[CLLocation alloc] initWithLatitude:venue.latitude longitude:venue.longitude]] <= rad) {
            [resultVenues addObject:venue];
        }
    }
    
    return resultVenues;
}

#pragma mark - GMSMapViewDelegate

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    [self.venueInfoView configure:marker.userData];
    if (!self.venueInfoView.visible) {
        [self.venueInfoView show:self.view];
    }
    
    return NO;
}

#pragma mark - DBVenueInfoViewDelegate

- (BOOL)db_venueViewInfoSelectionInfoEnabled:(DBVenueInfoView *)view {
    return [self.delegate db_venuesControllerContentSelectInfoEnabled];
}

- (BOOL)db_venueViewInfoSelectionEnabled:(DBVenueInfoView *)view {
    return [self.delegate db_venuesControllerContentSelectEnabled];
}

- (void)db_venueViewInfo:(DBVenueInfoView *)view clickedVenue:(Venue *)venue {
    if ([self.delegate db_venuesControllerContentSelectInfoEnabled]){
        [self.delegate db_venuesControllerContentDidSelectVenueInfo:venue];
    }
    
    [GANHelper analyzeEvent:@"venue_info_click" label:venue.venueId category:self.eventsCategory];
}

- (void)db_venueViewInfo:(DBVenueInfoView *)view didSelectVenue:(Venue *)venue {
    if ([self.delegate db_venuesControllerContentSelectEnabled]) {
        [self.delegate db_venuesControllerContentDidSelectVenue:venue];
    }
    
    [GANHelper analyzeEvent:@"venue_click" label:venue.venueId category:self.eventsCategory];
}

@end
