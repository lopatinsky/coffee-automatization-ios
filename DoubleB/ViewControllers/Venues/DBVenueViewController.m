//
//  DBVenueViewController.m
//  DoubleB
//
//  Created by Balaban Alexander on 01/08/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "DBVenueViewController.h"
#import "LocationHelper.h"
#import "UIAlertView+BlocksKit.h"

#import <GoogleMaps/GoogleMaps.h>

@interface DBVenueViewController ()<UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *labelDistance;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintDistanceWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrainSpaceLabelDistance_labelName;

@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelAddress;
@property (weak, nonatomic) IBOutlet UILabel *labelWorkHours;

@property (weak, nonatomic) IBOutlet UIImageView *clockImageView;
@property (weak, nonatomic) IBOutlet UIImageView *venueImageView;

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@end

@implementation DBVenueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self db_setTitle:self.venue.title];

    self.view.backgroundColor = [UIColor db_backgroundColor];

    self.labelName.text = self.venue.title;
    self.labelAddress.text = self.venue.address;
    self.labelWorkHours.text = self.venue.workingTime ?: NSLocalizedString(@"Пн-пт 8:00-20:00, сб-вс 11:00-18:00", nil);
    double dist = self.venue.distance;
    if (dist && dist > 0) {
        self.labelDistance.backgroundColor = [UIColor db_defaultColor];
        if (dist > 1) {
            self.labelDistance.text = [NSString stringWithFormat:NSLocalizedString(@"%.1f км", nil), dist];
            if (dist > 3) {
                self.labelDistance.backgroundColor = [UIColor fromHex:0xffa1aaaa];
            }
        } else {
            self.labelDistance.text = [NSString stringWithFormat:NSLocalizedString(@"%.0f м", nil), dist * 1000];
        }
        self.labelDistance.hidden = NO;
        self.constraintDistanceWidth.constant = 55;
    } else {
        self.labelDistance.hidden = YES;
        self.constraintDistanceWidth.constant = 0;
        self.constrainSpaceLabelDistance_labelName.constant = 0;
    }
    self.labelDistance.layer.cornerRadius = 5;
    
    [self.clockImageView templateImageWithName:@"time_icon_active.png"];
    [self.venueImageView templateImageWithName:@"map_icon_active.png"];

    self.mapView.myLocationEnabled = YES;
    [self.mapView setCamera:[GMSCameraPosition cameraWithLatitude:self.venue.location.latitude longitude:self.venue.location.longitude zoom:16]];
    GMSMarker *marker = [GMSMarker markerWithPosition:self.venue.location];
    marker.icon = [UIImage imageNamed:@"map_icon_active.png"];
    marker.map = self.mapView;
    
    [self setupPhoneButton];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [GANHelper analyzeScreen:@"Coffe_houses_item_screen"];
    
    [[LocationHelper sharedInstance] updateLocationWithCallback:^(CLLocation *location) {
        GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:location.coordinate coordinate:self.venue.location];
        
        [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds]];
    }];
}

- (void)didMoveToParentViewController:(UIViewController *)parent{
    if(!parent){
        [GANHelper analyzeEvent:@"back_arrow_pressed" category:VENUE_INFO_SCREEN];
    }
}

- (void)setupPhoneButton {
    if (self.venue.phone.length > 0) {
        CGRect frameimg = CGRectMake(0, 0, 21, 21);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frameimg];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [imageView templateImageWithName:@"phone_icon" tintColor:[UIColor whiteColor]];
        
        UIButton *someButton = [[UIButton alloc] initWithFrame:frameimg];
        [someButton addSubview:imageView];
        [someButton addTarget:self action:@selector(call) forControlEvents:UIControlEventTouchUpInside];
        [someButton setShowsTouchWhenHighlighted:YES];
        UIBarButtonItem *button =[[UIBarButtonItem alloc] initWithCustomView:someButton];
        self.navigationItem.rightBarButtonItem = button;
    }
}

- (void)call {
    NSString *phoneString = [NSString stringWithFormat:@"%@", self.venue.phone];
    [UIAlertView bk_showAlertViewWithTitle:self.venue.title message:phoneString cancelButtonTitle:NSLocalizedString(@"Отменить", nil) otherButtonTitles:@[NSLocalizedString(@"Позвонить", nil)]
                                   handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                       if (buttonIndex == 1) {
                                           NSString *phoneURLString = [NSString stringWithFormat:@"tel:%@", phoneString];
                                           NSURL *phoneURL = [NSURL URLWithString:phoneURLString];
                                           [[UIApplication sharedApplication] openURL:phoneURL];
                                       }
                                   }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    CGPoint point = [touch locationInView:self.view];
    
    if (CGRectContainsPoint(self.mapView.frame, point)) {
        [GANHelper analyzeEvent:@"map_scrolled" category:VENUE_INFO_SCREEN];
    }
    
    return YES;
}


@end
