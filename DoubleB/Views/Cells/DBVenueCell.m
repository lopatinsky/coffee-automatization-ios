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
@end

@implementation DBVenueCell

- (void)awakeFromNib {
    [self.moreInfoButton addTarget:self action:@selector(moreInfoButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.infoImageView templateImageWithName:@"info_icon"];
}

- (void)moreInfoButtonClick {
    if ([self.delegate respondsToSelector:@selector(db_venueCellDidSelectInfo:)]) {
        [self.delegate db_venueCellDidSelectInfo:self];
    }
}

@end
