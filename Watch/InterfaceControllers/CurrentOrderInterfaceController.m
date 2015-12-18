//
//  CurrentOrderInterfaceController.m
//  DoubleB
//
//  Created by Balaban Alexander on 23/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "ApplicationInteractionManager.h"
#import "OrderWatch.h"
#import "OrderPositionRowType.h"
#import "WatchNetworkManager.h"

#import "CurrentOrderInterfaceController.h"
#import "CreateOrderInterfaceController.h"

@interface CurrentOrderInterfaceController ()

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *orderInfoLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *placeLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceTable *orderPositionsTable;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *cancenOrderButton;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *priceLabel;

@property (nonatomic, strong) OrderWatch *order;

@end

@implementation CurrentOrderInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    self.order = [[ApplicationInteractionManager sharedManager] currentOrder];
    if (self.order) {
        [self updateView];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInfo) name:kWatchNetworkManagerOrderUpdated object:nil];
}

- (void)updateView {
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HH:mm"];
    [self.orderInfoLabel setText:[NSString stringWithFormat:@"Order #%@\n%@", self.order.orderId, [timeFormat stringFromDate:self.order.time]]];
    [self.priceLabel setText:[NSString stringWithFormat:@"%d₽", [self.order.total integerValue]]];
    [self.placeLabel setText:self.order.venueName];
    [self configureTableWithData:self.order.items];
}

//typedef NS_ENUM(int16_t, OrderStatus) {
//    OrderStatusNew = 0,
//    OrderStatusConfirmed = 5,
//    OrderStatusOnWay = 6,
//    OrderStatusDone = 1,
//    OrderStatusCanceled = 2,
//    OrderStatusCanceledBarista = 3
//};
- (void)updateInfo {
    if (![[ApplicationInteractionManager sharedManager] currentOrder]) {
        [WKInterfaceController reloadRootControllersWithNames:@[@"AddOrder"] contexts:nil];
    } else if ([[ApplicationInteractionManager sharedManager] currentOrder].status == 1 || [[ApplicationInteractionManager sharedManager] currentOrder].status == 2 ||
               [[ApplicationInteractionManager sharedManager] currentOrder].status == 3) {
        [WKInterfaceController reloadRootControllersWithNames:@[@"LastOrder"] contexts:nil];
    } else if (![[self.order orderId] isEqualToString:[[[ApplicationInteractionManager sharedManager] currentOrder] orderId]]) {
        [self updateView];
    }
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    [self updateUserActivity:@"com.empatika.openorder" userInfo:@{@"order_id": [self.order orderId]} webpageURL:nil];
    [WatchNetworkManager updateState:self.order];
    [self updateInfo];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [self invalidateUserActivity];
    [super didDeactivate];
}

- (void)configureTableWithData:(NSArray *)items {
    [self.orderPositionsTable setNumberOfRows:[items count] withRowType:@"PositionRow"];
    for (NSInteger i = 0; i < self.orderPositionsTable.numberOfRows; i++) {
        OrderPositionRowType *row = [self.orderPositionsTable rowControllerAtIndex:i];
        OrderItemWatch *orderItem = [items objectAtIndex:i];
        [row.positionName setText:[[orderItem position] name]];
        [row.positionPrice setText:[NSString stringWithFormat:@"%0.2f (x%d)", [[orderItem position] price], [orderItem count]]];
    }
}

#pragma mark - auxiliary
- (IBAction)cancelOrderButton {
    //  NSURLConnection to cancel order with current_order_id
    [WatchNetworkManager cancelOrder:self.order onController:self];
}

@end



