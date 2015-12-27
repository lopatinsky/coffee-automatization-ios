//
//  LastOrderInterfaceController.m
//  DoubleB
//
//  Created by Balaban Alexander on 23/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "ApplicationInteractionManager.h"
#import "LastOrderInterfaceController.h"

#import "OrderPositionRowType.h"

@interface LastOrderInterfaceController ()

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *placeLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceTable *orderPositionTable;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *reorderButton;
@property (nonatomic, strong) OrderWatch *order;

@end

@implementation LastOrderInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    self.order = [[ApplicationInteractionManager sharedManager] currentOrder];
    if (self.order) {
        [self updateView];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInfo) name:kWatchNetworkManagerOrderUpdated object:nil];
}

- (void)updateView {
    if (self.order.status == 0 || self.order.status == 5 || self.order.status == 6) {
        [WKInterfaceController reloadRootControllersWithNames:@[@"CurrentOrder"] contexts:nil];
    } else {
        [self.placeLabel setText:self.order.venueName];
        [self configureTableWithData:self.order.items];
    }
}

- (void)updateInfo {
    if (![[ApplicationInteractionManager sharedManager] currentOrder]) {
        [WKInterfaceController reloadRootControllersWithNames:@[@"AddOrder"] contexts:nil];
    } else {
        if (![[self.order orderId] isEqualToString:[[[ApplicationInteractionManager sharedManager] currentOrder] orderId]]) {
            self.order = [[ApplicationInteractionManager sharedManager] currentOrder];
            [self updateView];
        }
    }
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    [self updateUserActivity:@"com.empatika.openorder" userInfo:@{@"order_id": [self.order orderId]} webpageURL:nil];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [self invalidateUserActivity];
    [super didDeactivate];
}

- (void)configureTableWithData:(NSArray *)items {
    [self.orderPositionTable setNumberOfRows:[items count] withRowType:@"PositionRow"];
    for (NSInteger i = 0; i < self.orderPositionTable.numberOfRows; i++) {
        OrderPositionRowType *row = [self.orderPositionTable rowControllerAtIndex:i];
        OrderItemWatch *orderItem = [items objectAtIndex:i];
        [row.positionName setText:[[orderItem position] name]];
        [row.positionPrice setText:[NSString stringWithFormat:@"%0.2f (x%d)", [[orderItem position] price], [orderItem count]]];
    }
}

#pragma mark - Auxiliary
- (IBAction)createNewOrder {
    // TODO: push order info in context
    [self presentControllerWithName:@"CreateOrder" context:nil];
}

@end