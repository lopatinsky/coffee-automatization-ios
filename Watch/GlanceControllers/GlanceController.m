//
//  GlanceController.m
//  Camera Obscura Extension
//
//  Created by Balaban Alexander on 23/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "GlanceController.h"
#import "ApplicationInteractionManager.h"
#import "OrderWatch.h"


@interface GlanceController()
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceImage *iconImage;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceTimer *timerLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceGroup *progressImage;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *progressLabel;

@end


@implementation GlanceController

- (void)awakeWithContext:(id)context {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [super awakeWithContext:context];

    [self.progressImage setBackgroundImageNamed:@"circle-"];
    
}

- (void)willActivate {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [super willActivate];
    
    OrderWatch *order = [[ApplicationInteractionManager sharedManager] currentOrder];
    
    if (order) {
        if ([order.time compare:[NSDate date]] == NSOrderedDescending) {
            [self.timerLabel setDate:order.time];
            [self.timerLabel start];
            
            NSInteger startInterval = [order.creationTime timeIntervalSince1970];
            NSInteger endInterval = [order.time timeIntervalSince1970];
            
            NSInteger current = (int)[[NSDate date] timeIntervalSince1970] - startInterval;
            NSInteger period = endInterval - startInterval;
            
            double timeInterval = (double)period / 100;
            
            NSInteger startIndex = current /timeInterval;
            startIndex = startIndex >= 0 ? startIndex : 0;
            
            [self.progressImage startAnimatingWithImagesInRange:NSMakeRange(startIndex, 100) duration:(endInterval - current) repeatCount:1];
        } else {
            
        }
    } else {
        [self.timerLabel stop];
        [self.timerLabel setHidden:YES];
    }
//    [self.progressImage startAnimatingWithImagesInRange:NSMakeRange(1, 15) duration:0.3 repeatCount:1];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}


@end



