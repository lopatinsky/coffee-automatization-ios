//
//  DBOrdersTableViewController.m
//  DoubleB
//
//  Created by Balaban Alexander on 01/08/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBOrdersTableViewController.h"
#import "DBNewOrderViewController.h"
#import "Order.h"
#import "OrderItem.h"
#import "Venue.h"
#import "CoreDataHelper.h"
#import "DBOrderViewController.h"
#import "DBNewOrderViewController.h"
#import "UIAlertView+BlocksKit.h"
#import "Compatibility.h"
#import "OrderManager.h"
#import "DBAPIClient.h"
#import "IHSecureStore.h"
#import "DBSharePermissionViewController.h"

#import <Parse/Parse.h>

@interface DBOrdersTableViewController () /*<DBNewOrderViewControllerDelegate>*/

@property (weak, nonatomic) IBOutlet UITableViewCell *tableCell;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSArray *orders;

@property (nonatomic, strong) UILabel *labelNoOrders;

@end

@implementation DBOrdersTableViewController

- (instancetype)init {
    self = [super initWithNibName:nil bundle:nil];
    self.title = NSLocalizedString(@"Заказы", nil);
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dateFormatter = [NSDateFormatter new];
    self.orders = [NSMutableArray new];
    
    self.tableView.backgroundColor = [UIColor db_backgroundColor];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.rowHeight = 120;
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(updateHistory:) forControlEvents:UIControlEventValueChanged];
    
    self.dateFormatter.dateStyle = NSDateFormatterShortStyle;
    self.dateFormatter.timeStyle = NSDateFormatterShortStyle;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    self.labelNoOrders = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, self.view.frame.size.width - 40, 390)];
    self.labelNoOrders.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    self.labelNoOrders.numberOfLines = 0;
    self.labelNoOrders.text = NSLocalizedString(@"У вас пока нет заказов.\nЗаказ можно сделать из раздела \"Меню\"", nil);
    self.labelNoOrders.textAlignment = NSTextAlignmentCenter;
    self.labelNoOrders.textColor = [UIColor blackColor];
    self.labelNoOrders.backgroundColor = [UIColor clearColor];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadStatuses:) name:kDBStatusUpdatedNotification object:nil];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadContent];
    [self updateHistory:nil];

    [GANHelper analyzeScreen:HISTORY_SCREEN];
    
    self.tabBarController.tabBar.hidden = NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadContent{
    self.orders = [Order allOrders];
    [self.tableView reloadData];
    
    if ([self.orders count] == 0) {
        self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 400)];
        [self.tableView.tableHeaderView addSubview:self.labelNoOrders];
    } else {
        self.tableView.tableHeaderView = nil;
    }
}

#pragma mark - orders update

- (void)updateHistory:(id)sender{
    [GANHelper analyzeEvent:@"history_update" category:HISTORY_SCREEN];
    NSString *clientId = [[IHSecureStore sharedInstance] clientId];
    if(clientId){
        [[DBAPIClient sharedClient] GET:@"history"
                             parameters:@{@"client_id": clientId}
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    [GANHelper analyzeEvent:@"history_update_success" category:HISTORY_SCREEN];
                                    
                                    for(NSDictionary *orderDict in responseObject[@"orders"]){
                                        [self synchronizeOrderWithHistory:orderDict];
                                    }
                                    
                                    [[CoreDataHelper sharedHelper] save];
                                    [self reloadContent];
                                    
                                    if ([sender isKindOfClass:[UIRefreshControl class]]) {
                                        [sender endRefreshing];
                                    }
                                }
                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    [GANHelper analyzeEvent:@"history_update_failed" label:error.localizedDescription category:HISTORY_SCREEN];
                                    NSLog(@"%@", error);
                                    
                                    if ([sender isKindOfClass:[UIRefreshControl class]]) {
                                        [sender endRefreshing];
                                    }
                                }];
    }
}

- (void)synchronizeOrderWithHistory:(NSDictionary *)orderDictionary{
    NSString *newOrderId = [NSString stringWithFormat:@"%@", orderDictionary[@"order_id"]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"orderId == %@", newOrderId];
    Order *sameOrder = [[self.orders filteredArrayUsingPredicate:predicate] firstObject];
    
    if(sameOrder){
        [sameOrder synchronizeWithResponseDict:orderDictionary];
    } else {
        Order *ord = [[Order alloc] initWithResponseDict:orderDictionary];
        
        [[NSUserDefaults standardUserDefaults] setObject:ord.orderId forKey:@"lastOrderId"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [Compatibility registerForNotifications];
        [PFPush subscribeToChannelInBackground:[NSString stringWithFormat:[DBCompanyInfo sharedInstance].orderPushChannel, ord.orderId]];
        [PFPush subscribeToChannelInBackground:[DBCompanyInfo sharedInstance].companyPushChannel];
        
        [GANHelper trackNewOrderInfo:ord];
    }
}


- (void)reloadStatuses:(id)sender {
    if ([sender isKindOfClass:[NSNotification class]]) {
        NSNotification *notification = (NSNotification *)sender;
        //NSLog(@"%s",__PRETTY_FUNCTION__);
        //NSLog(@"%@", notification.userInfo);
        if (notification.userInfo[@"order_id"]) {
            NSUInteger k = [self.orders indexOfObjectPassingTest:^BOOL(Order *obj, NSUInteger idx, BOOL *stop) {
                BOOL b = [obj.orderId isEqualToString:notification.userInfo[@"order_id"]];
                *stop = b;
                return b;
            }];
            if (k != NSNotFound) {
                Order *order = self.orders[k];
                order.status = (OrderStatus)[notification.userInfo[@"order_status"] intValue];
                
                long long timestamp = [notification.userInfo[@"timestamp"] longLongValue];
                if(timestamp > 0){
                    order.time = [NSDate dateWithTimeIntervalSince1970:timestamp];
                }
                
                [[CoreDataHelper sharedHelper] save];
                
                [self reloadContent];
                
                NSString *notificationName = [kDBNotificationUpdatedOrder stringByAppendingFormat:@"_%@", order.orderId];
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:notificationName object:order]];
                //NSLog(@"%@", notificationName);
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.orders.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OrderCell"];
    
    if (!cell) {
        [[NSBundle mainBundle] loadNibNamed:@"OrderCell" owner:self options:nil];
        cell = self.tableCell;
        self.tableCell = nil;
    }
    
    Order *order = self.orders[indexPath.row];
    
    UILabel *labelOrder = (UILabel *)[cell viewWithTag:1];
    UILabel *labelDate = (UILabel *)[cell viewWithTag:2];
    UILabel *labelAddress = (UILabel *)[cell viewWithTag:3];
    UILabel *labelStatus = (UILabel *)[cell viewWithTag:4];
    UILabel *labelTotal = (UILabel *)[cell viewWithTag:5];
    UIImageView *imageViewPayment = (UIImageView *)[cell viewWithTag:6];
    UIImageView *imageViewVenue = (UIImageView *)[cell viewWithTag:7];
    
    UIColor *textColor;
    NSMutableAttributedString *orderString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"Заказ #%@", nil), [order orderId]]];
    
    if(order.status == OrderStatusNew || order.status == OrderStatusConfirmed || order.status == OrderStatusOnWay){
        [orderString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, 6)];
        [orderString addAttribute:NSForegroundColorAttributeName value:[UIColor db_defaultColor] range:[orderString.string rangeOfString:[NSString stringWithFormat:@"#%@", order.orderId]]];
        [imageViewVenue templateImageWithName:@"venue"];
        switch (order.paymentType) {
            case PaymentTypeCash:
                [imageViewPayment templateImageWithName:@"cash"];
                break;
            case PaymentTypeCard:
                [imageViewPayment templateImageWithName:@"card"];
                break;
            case PaymentTypeExtraType:
                [imageViewPayment templateImageWithName:@"mug_orders"];
                break;
            default:
                break;
        }
        
        textColor = [UIColor blackColor];
        labelStatus.textColor = [UIColor blackColor];
        labelStatus.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        
        switch (order.status) {
            case OrderStatusNew:
                labelStatus.text = [order.deliveryType intValue] == DeliveryTypeIdShipping ? NSLocalizedString(@"Ожидает подтверждения", nil) : NSLocalizedString(@"Готовится", nil);
                break;
            case OrderStatusConfirmed:
                labelStatus.text = NSLocalizedString(@"Подтвержден", nil);
                break;
            case OrderStatusOnWay:
                labelStatus.text = NSLocalizedString(@"В пути", nil);
                break;
                
            default:
                break;
        }
    }
    
    if(order.status == OrderStatusCanceledBarista || order.status == OrderStatusCanceled){
        [orderString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, 6)];
        [orderString addAttribute:NSForegroundColorAttributeName value:[UIColor fromHex:0xffe16941] range:[orderString.string rangeOfString:[NSString stringWithFormat:@"#%@", order.orderId]]];
        [imageViewVenue templateImageWithName:@"venue" tintColor:[UIColor db_grayColor]];
        switch (order.paymentType) {
            case PaymentTypeCash:
                [imageViewPayment templateImageWithName:@"cash" tintColor:[UIColor db_grayColor]];
                break;
            case PaymentTypeCard:
                [imageViewPayment templateImageWithName:@"card" tintColor:[UIColor db_grayColor]];
                break;
            case PaymentTypeExtraType:
                [imageViewPayment templateImageWithName:@"mug_orders" tintColor:[UIColor db_grayColor]];
                break;
            default:
                break;
        }
        textColor = [UIColor grayColor];
        labelStatus.text = NSLocalizedString(@"Отменен", nil);
        labelStatus.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14];
        labelStatus.textColor = [UIColor fromHex:0xffe16941];
    }
    
    if(order.status == OrderStatusDone){
        [orderString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, orderString.string.length)];
        [imageViewVenue templateImageWithName:@"venue" tintColor:[UIColor db_grayColor]];
        switch (order.paymentType) {
            case PaymentTypeCash:
                [imageViewPayment templateImageWithName:@"cash" tintColor:[UIColor db_grayColor]];
                break;
            case PaymentTypeCard:
                [imageViewPayment templateImageWithName:@"card" tintColor:[UIColor db_grayColor]];
                break;
            case PaymentTypeExtraType:
                [imageViewPayment templateImageWithName:@"mug_orders" tintColor:[UIColor db_grayColor]];
                break;
            default:
                break;
        }
        textColor = [UIColor grayColor];
        labelStatus.text = NSLocalizedString(@"Выдан", nil);
        labelStatus.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        labelStatus.textColor = [UIColor grayColor];
    }
    
    labelDate.textColor = textColor;
    labelTotal.textColor = textColor;
    labelAddress.textColor = textColor;
    
    labelOrder.attributedText = orderString;
    labelDate.text = order.formattedTimeString;
    labelAddress.text = [order.deliveryType intValue] == DeliveryTypeIdShipping ? order.shippingAddress : order.venue.address;
    labelTotal.text = [NSString stringWithFormat:@"%ld %@", (long)order.realTotal.integerValue, [Compatibility currencySymbol]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Order *order = self.orders[indexPath.row];
    DBOrderViewController *orderViewController = [DBOrderViewController new];
    orderViewController.order = order;
    orderViewController.hidesBottomBarWhenPushed = YES;
    
    NSString *eventLabel = [NSString stringWithFormat:@"%@;%@", order.orderId, [IHSecureStore sharedInstance].clientId];
    [GANHelper analyzeEvent:@"order_selected" label:eventLabel category:HISTORY_SCREEN];
    
    [self.navigationController pushViewController:orderViewController animated:YES];
}

/*- (void)newOrderViewController:(DBNewOrderViewController *)controller didFinishOrder:(Order *)order{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Успех", nil)
                                   message:NSLocalizedString(@"Заказ отправлен. Мы вас ждем!", nil)
                         cancelButtonTitle:NSLocalizedString(@"OK", nil)
                         otherButtonTitles:nil
                                   handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                       if(order.paymentType == PaymentTypeExtraType){
                                           DBSharePermissionViewController *shareVC = [DBSharePermissionViewController new];
                                           [self presentViewController:shareVC animated:YES completion:nil];
                                       }
                                   }];
}*/

@end
