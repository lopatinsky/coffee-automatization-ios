//
//  DBVenueCell.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 13.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBVenueCell.h"
#import "Venue.h"
#import "LocationHelper.h"

@interface DBVenueCell () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *moreInfoView;
@property (weak, nonatomic) IBOutlet UIButton *moreInfoButton;
@property (weak, nonatomic) IBOutlet UIImageView *infoImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintInfoViewWidth;
@property (nonatomic) double initialInfoViewWidth;
@end

@implementation DBVenueCell

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.venueDistanceLabel.layer setCornerRadius:5];
    [self.moreInfoButton addTarget:self action:@selector(moreInfoButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.initialInfoViewWidth = self.constraintInfoViewWidth.constant;
    
    [self.infoImageView templateImageWithName:@"info_icon"];
}

- (void)moreInfoButtonClick {
    if ([self.delegate respondsToSelector:@selector(db_venueCellDidSelectInfo:)]) {
        [self.delegate db_venueCellDidSelectInfo:self];
    }
}

- (void)configure:(Venue *)venue {
    _venue = venue;
    
    double dist = venue.distance;
    if (dist && dist > 0) {
        [self.venueDistanceLabel setBackgroundColor:[UIColor db_defaultColor]];
        if (dist > 1) {
            self.venueDistanceLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%.1f км", nil), dist];
            if (dist > 3) {
                [self.venueDistanceLabel setBackgroundColor:[UIColor fromHex:0xffa1aaaa]];
            }
        } else {
            self.venueDistanceLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%.0f м", nil), dist * 1000];
        }
        self.venueDistanceLabel.hidden = NO;
        self.constraintDistanceLabelWidth.constant = 55;
        self.constraintDistanceLabelAndVenueNameLabelSpace.constant = 5;
    } else {
        self.venueDistanceLabel.hidden = YES;
        self.constraintDistanceLabelWidth.constant = 0;
        self.constraintDistanceLabelAndVenueNameLabelSpace.constant = 0;
    }
    self.venueNameLabel.text = venue.title;
    self.venueAddressLabel.text = venue.address;
    self.venueWorkTimeLabel.text = venue.workingTime ?: NSLocalizedString(@"Пн-пт 8:00-20:00, сб-вс 11:00-18:00", nil);
}

- (void)setInfoButtonEnabled:(BOOL)infoButtonEnabled {
    _infoButtonEnabled = infoButtonEnabled;
    
    self.constraintInfoViewWidth.constant = _infoButtonEnabled ? self.initialInfoViewWidth : 0.f;
}

@end
