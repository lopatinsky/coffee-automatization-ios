//
//  DBNOVenueModelView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 16/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBNOVenueModuleView.h"
#import "DBAddressViewController.h"

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
    
    [self.venueImageView templateImageWithName:@"venue"];
    
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
        self.titleLabel.textColor = [UIColor db_errorColor];
        self.titleLabel.text = NSLocalizedString(@"Ошибка определения локации", nil);
    }
}

- (void)touchAtLocation:(CGPoint)location {
    [GANHelper analyzeEvent:@"venues_click" category:self.analyticsCategory];
    
    DBAddressViewController *addressController = [DBAddressViewController new];
//    addressController.view.frame = [[UIScreen mainScreen] bounds];
    addressController.hidesBottomBarWhenPushed = YES;
    
    [self.ownerViewController.navigationController pushViewController:addressController animated:YES];
}

@end
