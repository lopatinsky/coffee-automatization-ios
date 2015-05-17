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
    UITapGestureRecognizer *tapGestrureRecognizer = [[UITapGestureRecognizer alloc] init];
    tapGestrureRecognizer.delegate = self;
    [self.venueDistanceLabel addGestureRecognizer:tapGestrureRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    CGPoint point = [touch locationInView:self.contentView];
    
    [[LocationHelper sharedInstance] updateLocationWithCallback:^(CLLocation *location) {
        NSString *eventLabel = [NSString stringWithFormat:@"%@;%f;%f,%f", self.venue.title, self.venue.distance, location.coordinate.latitude, location.coordinate.longitude];
        
        if(CGRectContainsPoint(self.venueDistanceLabel.frame, point)){
        }
        
        if(CGRectContainsPoint(self.venueNameLabel.frame, point)){
        }
        
        if(CGRectContainsPoint(self.venueAddressLabel.frame, point)){
        }
        
        if(CGRectContainsPoint(self.venueWorkTimeLabel.frame, point)){
        }
    }];
    
    return YES;
}

@end
