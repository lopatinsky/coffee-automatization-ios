//
//  DBVenueInfoView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 14/01/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBVenueInfoView.h"
#import "Venue.h"
#import "LocationHelper.h"
#import "CoreDataHelper.h"

#import "UIGestureRecognizer+BlocksKit.h"

@interface DBVenueInfoView ()
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (weak, nonatomic) IBOutlet UIView *venueContentView;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *venueTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *venueAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *venueWorkingTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *disclosureIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintDistanceLabelWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintDistanceLabelAndVenueLabelSpacing;

@property (weak, nonatomic) IBOutlet UIButton *chooseVenueButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintChooseVenueView;

@property (weak, nonatomic) UIView *holder;

@end

@implementation DBVenueInfoView

+ (DBVenueInfoView *)create {
    DBVenueInfoView *infoView = [[[NSBundle mainBundle] loadNibNamed:@"DBVenueInfoView" owner:self options:nil] firstObject];
    
    return infoView;
}

- (void)awakeFromNib {
    [self.closeButton setTitle:NSLocalizedString(@"Закрыть", nil).uppercaseString forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    
    [self.distanceLabel.layer setCornerRadius:5];
    
    @weakify(self)
    [self.venueContentView addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self)
        if ([self.delegate respondsToSelector:@selector(db_venueViewInfo:clickedVenue:)]) {
            [self.delegate db_venueViewInfo:self clickedVenue:_venue];
        }
    }]];
    
    [self.chooseVenueButton setTitleColor:[UIColor db_defaultColor] forState:UIControlStateNormal];
    [self.chooseVenueButton setTitle:NSLocalizedString(@"Выбрать для оформления заказа", nil) forState:UIControlStateNormal];
    [self.chooseVenueButton addTarget:self action:@selector(chooseButtonClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)chooseButtonClick {
    if ([self.delegate respondsToSelector:@selector(db_venueViewInfo:didSelectVenue:)]) {
        [self.delegate db_venueViewInfo:self didSelectVenue:_venue];
    }
}

- (void)configure:(Venue *)venue {
    _venue = venue;
    
    [[LocationHelper sharedInstance] updateLocationWithCallback:^(CLLocation *location) {
        double dist = [location distanceFromLocation:[[CLLocation alloc] initWithLatitude:_venue.latitude longitude:_venue.longitude]] / 1000;
        _venue.distance = dist;
        [[CoreDataHelper sharedHelper] save];
        
        [self reloadDistanceLabel:dist];
    }];
    
    double dist = venue.distance;
    [self reloadDistanceLabel:dist];
    
    self.venueTitleLabel.text = venue.title;
    self.venueAddressLabel.text = venue.address;
    self.venueWorkingTimeLabel.text = venue.workingTime ?: NSLocalizedString(@"Пн-пт 8:00-20:00, сб-вс 11:00-18:00", nil);
}

- (void)reloadDistanceLabel:(double)dist {
    if (dist && dist > 0) {
        [self.distanceLabel setBackgroundColor:[UIColor db_defaultColor]];
        if (dist > 1) {
            self.distanceLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%.1f км", nil), dist];
            if (dist > 3) {
                [self.distanceLabel setBackgroundColor:[UIColor fromHex:0xffa1aaaa]];
            }
        } else {
            self.distanceLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%.0f м", nil), dist * 1000];
        }
        self.distanceLabel.hidden = NO;
        self.constraintDistanceLabelWidth.constant = 55;
        self.constraintDistanceLabelAndVenueLabelSpacing.constant = 5;
    } else {
        self.distanceLabel.hidden = YES;
        self.constraintDistanceLabelWidth.constant = 0;
        self.constraintDistanceLabelAndVenueLabelSpacing.constant = 0;
    }
}

- (void)setSelectionEnabled:(BOOL)selectionEnabled {
    _selectionEnabled = selectionEnabled;
    
    if (_selectionEnabled) {
        self.constraintChooseVenueView.constant = 40.f;
        CGRect rect = self.frame;
        rect.size.height = 140.f;
        self.frame = rect;
    } else {
        self.constraintChooseVenueView.constant = 0;
        CGRect rect = self.frame;
        rect.size.height = 100.f;
        self.frame = rect;
    }
}

- (void)show:(UIView *)holder {
    _holder = holder;
    
    self.frame = CGRectMake(0, _holder.frame.size.height, self.frame.size.width, self.frame.size.height);
    [_holder addSubview:self];
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = self.frame;
        rect.origin.y = _holder.frame.size.height - self.frame.size.height;
        self.frame = rect;
    } completion:^(BOOL finished) {
        _visible = YES;
    }];
}

- (void)hide {
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(0, _holder.frame.size.height, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        _visible = NO;
    }];
}

@end
