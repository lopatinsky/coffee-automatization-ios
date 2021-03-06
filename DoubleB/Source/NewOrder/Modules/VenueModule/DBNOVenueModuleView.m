//
//  DBNOVenueModelView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 16/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBNOVenueModuleView.h"
#import "DBShippingViewController.h"
#import "DBVenuesViewController.h"

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

+ (NSString *)xibName {
    return @"DBNOVenueModuleView";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.venueImageView templateImageWithName:@"map_icon_active"];
    
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
        if(_orderCoordinator.shippingManager.selectedAddress.valid){
            self.titleLabel.text = address;
            self.titleLabel.textColor = [UIColor blackColor];
        } else {
            self.titleLabel.text = NSLocalizedString(@"Введите адрес доставки", nil);
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
    } else {
        self.titleLabel.text = NSLocalizedString(@"Ошибка определения локации", nil);
        self.titleLabel.textColor = [UIColor db_errorColor];
    }
}

- (void)touchAtLocation:(CGPoint)location {
    [GANHelper analyzeEvent:@"venues_click" category:self.analyticsCategory];
    
    UIViewController *vc;
    if (_orderCoordinator.deliverySettings.deliveryType.typeId == DeliveryTypeIdShipping) {
        vc = [DBShippingViewController new];
    } else {
        vc = [DBVenuesViewController new];
        ((DBVenuesViewController *)vc).mode = DBVenuesViewControllerModeChooseVenue;
    }

    [self.ownerViewController.navigationController pushViewController:vc animated:YES];
}

@end
