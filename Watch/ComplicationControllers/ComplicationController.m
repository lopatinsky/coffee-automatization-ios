//
//  ComplicationController.m
//  Camera Obscura Extension
//
//  Created by Balaban Alexander on 23/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "ComplicationController.h"

#import "ApplicationInteractionManager.h"
#import "NSDate+Difference.h"

@interface ComplicationController ()

@end

@implementation ComplicationController

#pragma mark - Timeline Configuration

- (void)getSupportedTimeTravelDirectionsForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimeTravelDirections directions))handler {
    handler(CLKComplicationTimeTravelDirectionForward|CLKComplicationTimeTravelDirectionBackward);
}

- (void)getTimelineStartDateForComplication:(CLKComplication *)complication withHandler:(void(^)(NSDate * __nullable date))handler {
    handler(nil);
}

- (void)getTimelineEndDateForComplication:(CLKComplication *)complication withHandler:(void(^)(NSDate * __nullable date))handler {
    handler(nil);
}

- (void)getPrivacyBehaviorForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationPrivacyBehavior privacyBehavior))handler {
    handler(CLKComplicationPrivacyBehaviorShowOnLockScreen);
}

#pragma mark - Timeline Population

- (void)getCurrentTimelineEntryForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimelineEntry * __nullable))handler {
    CLKComplicationTimelineEntry *entry = nil;
    
    OrderWatch *order = [[ApplicationInteractionManager sharedManager] currentOrder];
    if (order && order.status == 0 && order.status == 5 && order.status == 6) {
        CLKComplicationTemplateModularSmallStackImage *stackTemplate = [[CLKComplicationTemplateModularSmallStackImage alloc] init];
        stackTemplate.line1ImageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"mug"]];
        
        stackTemplate.line2TextProvider = [CLKTimeTextProvider textProviderWithDate:order.time];
        entry = [CLKComplicationTimelineEntry entryWithDate:[NSDate date]
                                       complicationTemplate:stackTemplate];
    } else {
        CLKComplicationTemplateModularSmallSimpleImage *imageTemplate = [[CLKComplicationTemplateModularSmallSimpleImage alloc] init];
        imageTemplate.imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[UIImage imageNamed:@"mug"]];
        entry = [CLKComplicationTimelineEntry entryWithDate:[NSDate date]
                                       complicationTemplate:imageTemplate];
    }
    
    handler(entry);
}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication beforeDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> * __nullable entries))handler {
    // Call the handler with the timeline entries prior to the given date
    CLKComplicationTimelineEntry *entry = nil;
    if (complication.family == CLKComplicationFamilyModularSmall) {
        CLKComplicationTemplateModularSmallRingText *ringTemplate = [[CLKComplicationTemplateModularSmallRingText alloc] init];
        ringTemplate.textProvider = [CLKTextProvider textProviderWithFormat:@"16"];
        ringTemplate.fillFraction = 0.2;
        // Create the entry.
        entry = [CLKComplicationTimelineEntry entryWithDate:[NSDate date]
                                       complicationTemplate:ringTemplate];
    }
    
    if (complication.family == CLKComplicationFamilyCircularSmall) {
        
    }
    
    handler(@[entry]);
}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication afterDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> * __nullable entries))handler {
    // Call the handler with the timeline entries after to the given date
    handler(nil);
}

#pragma mark Update Scheduling

- (void)getNextRequestedUpdateDateWithHandler:(void(^)(NSDate * __nullable updateDate))handler {
    // Call the handler with the date when you would next like to be given the opportunity to update your complication content
    handler(nil);
}

#pragma mark - Placeholder Templates

- (void)getPlaceholderTemplateForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTemplate * __nullable complicationTemplate))handler {
    // This method will be called once per supported complication, and the results will be cached
    handler(nil);
}

@end
