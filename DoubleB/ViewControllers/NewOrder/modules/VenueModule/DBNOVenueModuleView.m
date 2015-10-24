//
//  DBNOVenueModelView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 16/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBNOVenueModuleView.h"
#import "DBShippingViewController.h"
#import "DBVenuesTableViewController.h"

#import "OrderCoordinator.h"
#import "LocationHelper.h"
#import "NetworkManager.h"

#import "Venue.h"

@interface DBNOVenueModuleView ()
@property (weak, nonatomic) IBOutlet UIImageView *venueImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *activityIndicator;

@property (strong, nonatomic) OrderCoordinator *orderCoordinator;

@end

@implementation DBNOVenueModuleView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBNOVenueModuleView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.venueImageView templateImageWithName:@"map_icon"];
    
    _orderCoordinator = [OrderCoordinator sharedInstance];
    [_orderCoordinator addObserver:self withKeyPaths:@[CoordinatorNotificationNewVenue, CoordinatorNotificationNewShippingAddress, CoordinatorNotificationNewDeliveryType] selector:@selector(reload)];
}

- (void)dealloc {
    [_orderCoordinator removeObserver:self];
}

- (void)reload:(BOOL)animated {
    [super reload:animated];
    
    if (_orderCoordinator.deliverySettings.deliveryType.typeId == DeliveryTypeIdShipping) {
        NSString *address = [_orderCoordinator.shippingManager.selectedAddress formattedAddressString:DBAddressStringModeNormal];
        if(address && address.length > 0){
            self.titleLabel.text = address;
            self.titleLabel.textColor = [UIColor blackColor];
            self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.f];
        } else {
            self.titleLabel.text = NSLocalizedString(@"Введите адрес доставки", nil);
            self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.f];
            self.titleLabel.textColor = [UIColor db_errorColor];
        }
    } else {
        if (_orderCoordinator.orderManager.venue) {
            [self setVenue:_orderCoordinator.orderManager.venue];
        } else {
            [self.activityIndicator startAnimating];
            [[LocationHelper sharedInstance] updateLocationWithCallback:^(CLLocation *location) {
                _orderCoordinator.orderManager.location = location;
                
                if (location) {
                    [[NetworkManager sharedManager] addPendingOperation:NetworkOperationFetchVenues withUserInfo:@{@"location": location}];
                } else {
                    [self setVenue:[[Venue storedVenues] firstObject]];
                }
                
                [self.activityIndicator stopAnimating];
            }];
        }
    }
}

- (void)setVenue:(Venue *)venue{
    if (venue) {
        self.titleLabel.text = venue.title;
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.f];
    } else {
        self.titleLabel.text = NSLocalizedString(@"Ошибка определения локации", nil);
        self.titleLabel.textColor = [UIColor db_errorColor];
        self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.f];
    }
}

- (void)touchAtLocation:(CGPoint)location {
    [GANHelper analyzeEvent:@"venues_click" category:self.analyticsCategory];
    
    UIViewController *vc;
    if (_orderCoordinator.deliverySettings.deliveryType.typeId == DeliveryTypeIdShipping) {
        vc = [DBShippingViewController new];
    } else {
        vc = [DBVenuesTableViewController new];
    }
    vc.hidesBottomBarWhenPushed = YES;
    
    [self.ownerViewController.navigationController pushViewController:vc animated:YES];
}

@end
