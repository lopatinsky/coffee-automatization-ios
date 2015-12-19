//
//  DBOrderViewController.m
//  DoubleB
//
//  Created by Balaban Alexander on 01/08/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBOrderViewController.h"
#import "CoreDataHelper.h"
#import "DBOrderItemCell.h"
#import "DBOrderViewFooter.h"
#import "DBOrderViewHeader.h"
#import "Venue.h"
#import "OrderItem.h"
#import "DBMenuPosition.h"
#import "DBAPIClient.h"
#import "LocationHelper.h"
#import "OrderManager.h"
#import "DBOrderReturnView.h"
#import "IHSecureStore.h"
#import "OrderCoordinator.h"
#import "DBCompanyInfo.h"

#import "UIAlertView+BlocksKit.h"

#import <GoogleMaps/GoogleMaps.h>

@interface DBOrderViewController ()<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, DBOrderReturnViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) DBOrderViewHeader *viewHeader;
@property (strong, nonatomic) DBOrderViewFooter *viewFooter;

@property (strong, nonatomic) DBOrderReturnView *returnCauseView;

//@property (weak, nonatomic) ShareManager *shareManager;

@end

@implementation DBOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.edgesForExtendedLayout = UIRectEdgeTop;
    
    self.view.backgroundColor = [UIColor db_backgroundColor];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor db_backgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    NSString *temp = [NSString stringWithFormat:NSLocalizedString(@"Заказ #%@", nil), self.order.orderNumber];
    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithString:temp];
    [attributed setAttributes:@{
            NSForegroundColorAttributeName: [UIColor whiteColor],
            NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:16]
    } range:NSMakeRange(0, attributed.string.length)];

    [attributed addAttribute:NSForegroundColorAttributeName
                       value:[UIColor whiteColor]
                       range:[attributed.string rangeOfString:[NSString stringWithFormat:@"#%@", self.order.orderNumber]]];

    UILabel *titleLabel = [UILabel new];
    titleLabel.attributedText = attributed;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleLabel setFrame:CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y, attributed.size.width, attributed.size.height)];
    
    self.navigationItem.titleView = titleLabel;
    
    self.viewHeader = [[DBOrderViewHeader alloc] initWithOrder:self.order];
    
    self.viewFooter = [[DBOrderViewFooter alloc] initWithOrder:self.order];
    self.tableView.tableFooterView = self.viewFooter;

    [self reloadStatusInfo:nil];
    
    NSString *notificationName = [kDBNotificationUpdatedOrder stringByAppendingFormat:@"_%@", self.order.orderId];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadStatusInfo:) name:notificationName object:nil];
    
    [self.tableView reloadData];
}         

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [GANHelper analyzeScreen:ORDER_HISTORY_SCREEN];
    [self reloadCancelRepeatButton];
    
//    self.shareManager = [ShareManager sharedManager];
//    if ([self.shareManager shareSuggestionIsAvailable]) {
//        [self.shareManager showOnViewController:self];
//    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(self.scrollContentToBottom){
        [UIView animateWithDuration:1 animations:^{
            double contentOffset = self.tableView.contentSize.height - self.tableView.frame.size.height;
            if(contentOffset > self.tableView.contentOffset.y){
                [self.tableView setContentOffset:CGPointMake(0, contentOffset)];
            }
        }];
    }
}


- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (!parent) {
        [GANHelper analyzeEvent:@"back_arrow_pressed" category:ORDER_HISTORY_SCREEN];
    }
}

- (void)reloadStatusInfo:(NSNotification *)notification {
    if(notification){
        self.order = (Order *)notification.object;
    }
    
    self.viewHeader.labelStatus.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    self.viewHeader.labelStatus.textColor = [UIColor blackColor];
    
    switch (self.order.status) {
        case OrderStatusNew:
            self.viewHeader.labelStatus.text = [self.order.deliveryType intValue] == DeliveryTypeIdShipping ? NSLocalizedString(@"Ожидает подтверждения", nil) : NSLocalizedString(@"Готовится", nil);
            break;
        case OrderStatusConfirmed:
            self.viewHeader.labelStatus.text =  NSLocalizedString(@"Подтвержден", nil);
            break;
        case OrderStatusOnWay:
            self.viewHeader.labelStatus.text =  NSLocalizedString(@"В пути", nil);
            break;
        case OrderStatusCanceledBarista:
        case OrderStatusCanceled:
            self.viewHeader.labelStatus.text =  @"";
            break;
        case OrderStatusDone:
            self.viewHeader.labelStatus.text =  NSLocalizedString(@"Выдан", nil);
            break;
            
        default:
            break;
    }

    if (self.order.status == OrderStatusCanceled || self.order.status == OrderStatusCanceledBarista) {
        self.viewHeader.labelPaymentStatus.textColor = [UIColor fromHex:0xffe16941];
        self.viewHeader.labelPaymentStatus.text = NSLocalizedString(@"Отменен", nil);
        self.viewHeader.imageViewPaymentStatus.image = [UIImage imageNamed:@"canceled"];
    } else if (self.order.paymentType == PaymentTypeCard || self.order.paymentType == PaymentTypePayPal ||
               self.order.paymentType == PaymentTypeExtraType || self.order.status == OrderStatusDone) {
        self.viewHeader.labelPaymentStatus.textColor = [UIColor db_defaultColor];
        self.viewHeader.labelPaymentStatus.text = NSLocalizedString(@"Оплачен", nil);
        [self.viewHeader.imageViewPaymentStatus templateImageWithName:@"paid"];
    } else {
        self.viewHeader.labelPaymentStatus.textColor = [UIColor grayColor];
        self.viewHeader.labelPaymentStatus.text = NSLocalizedString(@"Не оплачен", nil);
        self.viewHeader.imageViewPaymentStatus.image = [UIImage imageNamed:@"not_paid"];
    }
    

    self.viewFooter.labelDate.text = [NSString stringWithFormat:[DBTextResourcesHelper db_preparationOrderCellString], self.order.formattedTimeString];
}

- (void)cancelOrder:(DBOrderCancelReason)reason reasonText:(NSString *)reasonText {
    NSString *clientId = [IHSecureStore sharedInstance].clientId;
    NSString *eventLabel = [NSString stringWithFormat:@"%@;%@", self.order.orderId, clientId];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[DBAPIClient sharedClient] POST:@"return"
                          parameters:@{@"order_id": self.order.orderId,
                                       @"reason_id": @(reason),
                                       @"reason_text": reasonText ?: @""}
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 [GANHelper analyzeEvent:@"cancel_order_success" label:eventLabel category:ORDER_HISTORY_SCREEN];
                                 //NSLog(@"%@", responseObject);
                                 [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                 self.order.status = OrderStatusCanceled;
                                 [[CoreDataHelper sharedHelper] save];
                                 [self reloadCancelRepeatButton];
                                 [self reloadStatusInfo:nil];
                             }
                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 NSString *errorEventLabel = [eventLabel stringByAppendingString:[NSString stringWithFormat:@";%@", error.localizedDescription]];
                                 [GANHelper analyzeEvent:@"cancel_order_failed" label:errorEventLabel category:ORDER_HISTORY_SCREEN];
                                 
                                 NSLog(@"%@", error);
                                 [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                 if (operation.response.statusCode == 412) {
                                     [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Ошибка", nil)
                                                                    message:operation.responseObject[@"description"]
                                                          cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil handler:nil];
                                 }
                             }];
    
}

- (void)reloadCancelRepeatButton {
    UIButton *button = [UIButton new];
    button.contentEdgeInsets = UIEdgeInsetsMake(3, 0, 0, 0);
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14];
    
    NSString *orderString = @"";
    if (self.order.status == OrderStatusNew || self.order.status == OrderStatusConfirmed || self.order.status == OrderStatusOnWay) {
        orderString = NSLocalizedString(@"Отменить", nil);
        [button addTarget:self action:@selector(clickCancel:) forControlEvents:UIControlEventTouchUpInside];
        
        if([DBCompanyInfo sharedInstance].companyPOS == DBCompanyPOSIIko){
            button = nil;
        }
    } else {
        orderString = NSLocalizedString(@"Повторить", nil);
        [button addTarget:self action:@selector(clickRepeat:) forControlEvents:UIControlEventTouchUpInside];
    }
    [button setTitle:orderString forState:UIControlStateNormal];
    CGSize size = [orderString sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Medium" size:14]}];
    button.frame = CGRectMake(0, 0, size.width, 35);
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)clickCancel:(UIButton *)sender{
    NSString *clientId = [IHSecureStore sharedInstance].clientId;
    NSString *eventLabel = [NSString stringWithFormat:@"%@;%@", self.order.orderId, clientId];
    [GANHelper analyzeEvent:@"cancel_order_button_pressed" label:eventLabel category:ORDER_HISTORY_SCREEN];
    
    self.returnCauseView = [DBOrderReturnView new];
    self.returnCauseView.delegate = self;
    [self.returnCauseView showOnView:self.navigationController.view];
}

- (void)clickRepeat:(UIButton *)sender {
    [GANHelper analyzeEvent:@"repeat_order_button_pressed" category:ORDER_HISTORY_SCREEN];
//    DBNewOrderViewController *newOrderController = [DBNewOrderViewController new];
//    newOrderController.repeatedOrder = self.order;
//    [self.navigationController pushViewController:newOrderController animated:YES];
    
    [[OrderCoordinator sharedInstance].itemsManager flushCache];
    [[OrderCoordinator sharedInstance].bonusItemsManager flushCache];
    [[OrderCoordinator sharedInstance].orderManager flushCache];
    
    [[OrderCoordinator sharedInstance].itemsManager overrideItems:self.order.items];
    [OrderCoordinator sharedInstance].orderManager.paymentType = self.order.paymentType;
    
    Venue *venue = [Venue venueById:self.order.venueId];
    if(venue)
        [OrderCoordinator sharedInstance].orderManager.venue = venue;
    
    [[ApplicationManager sharedInstance] moveToScreen:ApplicationScreenOrder animated:YES];
//    [self.navigationController popToRootViewControllerAnimated:YES];
//    [self showAlert:@"Позиции из заказа успешно добавлены в корзину!"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return self.order.items.count;
    }
    if(section == 1){
        return self.order.bonusItems.count;
    }
    if(section == 2){
        return self.order.giftItems.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBOrderItemCell *cell;
    
    OrderItem *item;
    if(indexPath.section == 0){
        item = self.order.items[indexPath.row];
    }
    if(indexPath.section == 1){
        item = self.order.bonusItems[indexPath.row];
    }
    if(indexPath.section == 2){
        item = self.order.giftItems[indexPath.row];
    }
    
    if(item.position.hasImage){
        cell = [tableView dequeueReusableCellWithIdentifier:@"DBOrderItemCell"];
        
        if (!cell) {
            cell = [[DBOrderItemCell alloc] initWithType:DBOrderItemCellTypeFull];
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"DBOrderItemCompactCell"];
        
        if (!cell) {
            cell = [[DBOrderItemCell alloc] initWithType:DBOrderItemCellTypeCompact];
        }
    }
    
    cell.orderItem = item;
    
    [cell configure];
    cell.panGestureRecognizer.delegate = self;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    OrderItem *item;
    if(indexPath.section == 0){
        item = self.order.items[indexPath.row];
    }
    if(indexPath.section == 1){
        item = self.order.bonusItems[indexPath.row];
    }
    if(indexPath.section == 2){
        item = self.order.giftItems[indexPath.row];
    }
    
    if(item.position.hasImage){
        return 100;
    } else {
        return  60;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return 111.f;
    } else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section == 0){
        UIView *header = self.viewHeader;
        return header;
    } else {
        return nil;
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

#pragma mark - DBOrderReturnViewDelegate

- (void)db_orderReturnView:(DBOrderReturnView *)view DidSelectCause:(DBOrderCancelReason)cause{
    [self cancelOrder:cause reasonText:nil];
    [self.returnCauseView hide];
}

- (void)db_orderReturnView:(DBOrderReturnView *)view DidSelectOtherCause:(NSString *)cause{
    [self cancelOrder:DBOrderCancelReasonOther reasonText:cause];
    [self.returnCauseView hide];
}

- (void)db_orderReturnViewDidCancel:(DBOrderReturnView *)view{
    [self.returnCauseView hide];
}

@end
