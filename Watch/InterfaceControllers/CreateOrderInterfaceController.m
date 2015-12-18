//
//  CreateOrderInterfaceController.m
//  DoubleB
//
//  Created by Balaban Alexander on 23/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "ApplicationInteractionManager.h"
#import "WatchNetworkManager.h"
#import "CreateOrderInterfaceController.h"

@interface CreateOrderInterfaceController ()
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfacePicker *timePicker;
@property (nonatomic, strong) NSMutableDictionary *items;
@property (nonatomic, strong) NSArray *sortedItems;
@property (nonatomic) NSInteger currentIndex;

@end

@implementation CreateOrderInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    self.items = [NSMutableDictionary new];
    self.currentIndex = 0;
    
    NSArray *timeslots = [[[ApplicationInteractionManager sharedManager] currentOrder] timeSlots];
    for (NSDictionary *slot in timeslots) {
        NSString *numberString;
        NSScanner *scanner = [NSScanner scannerWithString:slot[@"title"]];
        NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
        [scanner scanCharactersFromSet:numbers intoString:&numberString];
        if (numberString) {
            [self.items setObject:slot[@"id"] forKey:numberString];
        } else {
            [self.items setObject:slot[@"id"] forKey:@"now"];
        }
    }
    
    NSArray *its = [[self.items allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ([obj1 isEqualToString:@"now"]) {
            return -1;
        } else if ([obj2 isEqualToString:@"now"]) {
            return 1;
        } else {
            return [obj1 compare:obj2 options:NSNumericSearch];
        }
    }];
    self.sortedItems = its;
    NSMutableArray *wkItems = [NSMutableArray new];
    for (NSString *item in its) {
        WKPickerItem *it = [WKPickerItem new];
        it.title = item;
        it.caption = @"time";
        [wkItems addObject:it];
    }
    [self.timePicker setItems:wkItems];
    [self.timePicker focus];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInfo) name:kWatchNetworkManagerOrderUpdated object:nil];
}

- (void)updateInfo {
    if ([[ApplicationInteractionManager sharedManager] currentOrder].status == 0 || [[ApplicationInteractionManager sharedManager] currentOrder].status == 5 ||
        [[ApplicationInteractionManager sharedManager] currentOrder].status == 6) {
        [WKInterfaceController reloadRootControllersWithNames:@[@"CurrentOrder"] contexts:nil];
    } else {
        [WKInterfaceController reloadRootControllersWithNames:@[@"LastOrder"] contexts:nil];
    }
}

- (void)willActivate { 
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (IBAction)pickerChanged:(NSInteger)value {
    [[WKInterfaceDevice currentDevice] playHaptic:WKHapticTypeClick];
    self.currentIndex = value;
}

#pragma marl - User-Defined

- (IBAction)createOrder {
    NSMutableDictionary *requestObject = [NSMutableDictionary dictionaryWithDictionary:[[[ApplicationInteractionManager sharedManager] currentOrder] requestObject]];
    NSString *slotId = self.items[self.sortedItems[self.currentIndex]];
    [requestObject setObject:slotId forKey:@"delivery_slot_id"];
    [WatchNetworkManager makeReorder:requestObject onController:self];
}

@end



