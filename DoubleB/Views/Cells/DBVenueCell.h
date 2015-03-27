//
//  DBVenueCell.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 13.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Venue;

@interface DBVenueCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *venueDistanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *venueNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *venueAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *venueWorkTimeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintDistanceLabelWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintDistanceLabelAndVenueNameLabelSpace;

@property (strong, nonatomic) Venue *venue;

@end
