//
//  DBVenueCell.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 13.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Venue;
@class DBVenueCell;

@protocol DBVenueCellDelegate <NSObject>
- (void)db_venueCellDidSelectInfo:(DBVenueCell *)cell;
@end

@interface DBVenueCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *venueDistanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *venueNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *venueAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *venueWorkTimeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintDistanceLabelWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintDistanceLabelAndVenueNameLabelSpace;

@property (strong, nonatomic) Venue *venue;
@property (weak, nonatomic) id<DBVenueCellDelegate> delegate;
@property (nonatomic) BOOL infoButtonEnabled;

- (void)configure:(Venue *)venue;

@end
