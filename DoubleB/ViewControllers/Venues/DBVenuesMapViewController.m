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

#import <GoogleMaps/GoogleMaps.h>

@interface DBVenuesMapViewController ()<GMSMapViewDelegate>
@property (nonatomic, strong) NSArray *venues;

@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) DBVenueInfoView *venueInfoView;
@end

@implementation DBVenuesMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView = [GMSMapView new];
    self.mapView.delegate = self;
    self.mapView.myLocationEnabled = YES;
    
    [self.view addSubview:self.mapView];
    self.mapView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.mapView alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self.view];
    
    self.venues = [Venue storedVenues];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateVenuesState) name:kDBConcurrentOperationFetchVenuesFinished object:nil];
    
    self.venueInfoView = [DBVenueInfoView create];
    self.venueInfoView.choiceEnabled = self.mode == DBVenuesViewControllerModeChooseVenue;
    
    [self setupCamera];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [GANHelper analyzeScreen:self.eventsCategory];
    [GANHelper analyzeEvent:@"all_venues_show" category:self.eventsCategory];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)update {
    [self setupCamera];
}

- (void)setupCamera {
    if (self.mapView.myLocation) {
        [self.mapView setCamera:[GMSCameraPosition cameraWithLatitude:self.mapView.myLocation.coordinate.latitude
                                                            longitude:self.mapView.myLocation.coordinate.longitude
                                                                 zoom:14]];
    } else {
        if (self.venues.count > 1) {
            GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:((Venue*)self.venues[0]).location coordinate:((Venue*)self.venues[1]).location];
            for (int i = 2; i < self.venues.count; i++) {
                bounds = [bounds includingCoordinate:((Venue*)self.venues[i]).location];
            }
            [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds]];
        } else {
            Venue *venue = self.venues.firstObject;
            [self.mapView setCamera:[GMSCameraPosition cameraWithLatitude:venue.location.latitude
                                                                longitude:venue.location.longitude
                                                                     zoom:14]];
        }
        
        [[LocationHelper sharedInstance] updateLocationWithCallback:^(CLLocation *location) {
            GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:location.coordinate coordinate:((Venue*)self.venues[1]).location];
            for (int i = 2; i < self.venues.count; i++) {
                bounds = [bounds includingCoordinate:((Venue*)self.venues[i]).location];
            }
            [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds]];
            [self.mapView setCamera:[GMSCameraPosition cameraWithLatitude:location.coordinate.latitude
                                                                longitude:location.coordinate.longitude
                                                                     zoom:14]];
        }];
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
        marker.icon = [UIImage imageNamed:@"venue.png"];
        marker.map = self.mapView;
        marker.userData = venue;
    }
}

#pragma mark - GMSMapViewDelegate

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    [self.venueInfoView configure:marker.userData];
    if (!self.venueInfoView.visible) {
        [self.venueInfoView show:self.view];
    }
    
    return NO;
}

@end
