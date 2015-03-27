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
            [GANHelper analyzeEvent:@"item_click_distance" label:eventLabel category:@"Coffee_houses_screen"];
        }
        
        if(CGRectContainsPoint(self.venueNameLabel.frame, point)){
            [GANHelper analyzeEvent:@"item_click_title" label:eventLabel category:@"Coffee_houses_screen"];
        }
        
        if(CGRectContainsPoint(self.venueAddressLabel.frame, point)){
            [GANHelper analyzeEvent:@"item_click_address" label:eventLabel category:@"Coffee_houses_screen"];
        }
        
        if(CGRectContainsPoint(self.venueWorkTimeLabel.frame, point)){
            [GANHelper analyzeEvent:@"item_click_work_time" label:eventLabel category:@"Coffee_houses_screen"];
        }
    }];
    
    return YES;
}

@end
