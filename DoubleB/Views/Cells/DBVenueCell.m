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

@end

@implementation DBVenueCell

- (void)awakeFromNib {
    self.moreInfoLabel.textColor = [UIColor db_defaultColor];
    self.moreInfoLabel.text = NSLocalizedString(@"Информация", nil);
    
    [self.moreInfoButton addTarget:self action:@selector(moreInfoButtonClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)moreInfoButtonClick {
    if ([self.delegate respondsToSelector:@selector(db_venueCellDidSelectInfo:)]) {
        [self.delegate db_venueCellDidSelectInfo:self];
    }
}

@end
