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
#import "MBProgressHUD.h"
#import "DBAPIClient.h"
#import "DBNewOrderViewController.h"
#import "Compatibility.h"
#import "LocationHelper.h"
#import "OrderManager.h"
#import "DBOrderReturnView.h"

#import "UIAlertView+BlocksKit.h"
#import "UIGestureRecognizer+BlocksKit.h"

#import <GoogleMaps/GoogleMaps.h>

@interface DBOrderViewController ()<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, DBOrderReturnViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) DBOrderViewHeader *viewHeader;
@property (strong, nonatomic) DBOrderViewFooter *viewFooter;

@property (nonatomic, strong) NSMutableArray *items;

@property (strong, nonatomic) DBOrderReturnView *returnCauseView;

@end

@implementation DBOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.topItem.title = @"";
    self.edgesForExtendedLayout = UIRectEdgeTop;
    
    self.items = [NSMutableArray new];
    self.view.backgroundColor = [UIColor db_backgroundColor];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor db_backgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.items = [NSMutableArray arrayWithArray:self.order.items];
    NSString *temp = [NSString stringWithFormat:NSLocalizedString(@"Заказ #%@", nil), self.order.orderId];
    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithString:temp];
    [attributed setAttributes:@{
            NSForegroundColorAttributeName: [UIColor whiteColor],
            NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:16]
    } range:NSMakeRange(0, attributed.string.length)];

    [attributed addAttribute:NSForegroundColorAttributeName
                       value:[UIColor whiteColor]
                       range:[attributed.string rangeOfString:[NSString stringWithFormat:@"#%@", self.order.orderId]]];

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
    [GANHelper analyzeScreen:@"Order_info_screen"];
    [self reloadCancelRepeatButton];
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
        [GANHelper analyzeEvent:@"back_arrow" label:self.order.orderId category:@"Order_info_screen"];
    }
}

- (void)reloadStatusInfo:(NSNotification *)notification {
    if(notification){
        self.order = (Order *)notification.object;
    }
    
    OrderStatus status = self.order.status;
    switch (status) {
        case OrderStatusCanceledServer:
        case OrderStatusCanceled:
            self.viewHeader.labelStatus.text = @"";
            break;
        case OrderStatusDone:
            self.viewHeader.labelStatus.text = NSLocalizedString(@"Выдан", nil);
            self.viewHeader.labelStatus.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
            self.viewHeader.labelStatus.textColor = [UIColor blackColor];
            break;
        case OrderStatusNew:
            self.viewHeader.labelStatus.text = NSLocalizedString(@"Готовится", nil);
            self.viewHeader.labelStatus.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
            self.viewHeader.labelStatus.textColor = [UIColor blackColor];
        default:
            break;
    }

    if (status == OrderStatusCanceled || status == OrderStatusCanceledServer) {
        self.viewHeader.labelPaymentStatus.textColor = [UIColor fromHex:0xffe16941];
        self.viewHeader.labelPaymentStatus.text = NSLocalizedString(@"Отменен", nil);
        self.viewHeader.imageViewPaymentStatus.image = [UIImage imageNamed:@"canceled"];
    } else if (self.order.paymentType == PaymentTypeCard || self.order.paymentType == PaymentTypeExtraType ||
               status == OrderStatusDone) {
        self.viewHeader.labelPaymentStatus.textColor = [UIColor db_defaultColor];
        self.viewHeader.labelPaymentStatus.text = NSLocalizedString(@"Оплачен", nil);
        [self.viewHeader.imageViewPaymentStatus templateImageWithName:@"paid"];
    } else {
        self.viewHeader.labelPaymentStatus.textColor = [UIColor grayColor];
        self.viewHeader.labelPaymentStatus.text = NSLocalizedString(@"Не оплачен", nil);
        self.viewHeader.imageViewPaymentStatus.image = [UIImage imageNamed:@"not_paid"];
    }
    
    // Update time
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    self.viewFooter.labelDate.text = [NSString stringWithFormat:NSLocalizedString(@"Готов к %@", nil), [formatter stringFromDate: self.order.createdAt]];
}

- (void)cancelOrder{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[DBAPIClient sharedClient] POST:@"return" parameters:@{@"order_id": self.order.orderId}
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 //NSLog(@"%@", responseObject);
                                 [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                 self.order.status = OrderStatusCanceled;
                                 [[CoreDataHelper sharedHelper] save];
                                 [self reloadCancelRepeatButton];
                                 [self reloadStatusInfo:nil];
                                 [GANHelper analyzeEvent:@"order_cancel_success"
                                                   label:self.order.orderId
                                                category:@"Order_info_screen"];
                             }
                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 NSLog(@"%@", error);
                                 [GANHelper analyzeEvent:@"order_cancel_failure"
                                                   label:[NSString stringWithFormat:@"%@,%@", self.order.orderId, error.localizedFailureReason]
                                                category:@"Order_info_screen"];
                                 [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                 if (operation.response.statusCode == 412) {
                                     [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Ошибка", nil)
                                                                    message:operation.responseObject[@"description"]
                                                          cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil handler:nil];
                                 }
                             }];
    
    [GANHelper analyzeEvent:@"order_cancel_click" label:self.order.orderId category:@"Order_info_screen"];
}

- (void)reloadCancelRepeatButton {
    UIButton *button = [UIButton new];
    button.contentEdgeInsets = UIEdgeInsetsMake(3, 0, 0, 0);
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14];
    
    NSString *orderString = @"";
    if (self.order.status == OrderStatusNew) {
        orderString = NSLocalizedString(@"Отменить", nil);
        [button addTarget:self action:@selector(clickCancel:) forControlEvents:UIControlEventTouchUpInside];
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
    self.returnCauseView = [DBOrderReturnView new];
    self.returnCauseView.delegate = self;
    [self.returnCauseView showOnView:self.navigationController.view];
}

- (void)clickRepeat:(UIButton *)sender {
    DBNewOrderViewController *newOrderController = [DBNewOrderViewController new];
    newOrderController.repeatedOrder = self.order;
    [self.navigationController pushViewController:newOrderController animated:YES];
    
    [GANHelper analyzeEvent:@"order_repeat_click" label:self.order.orderId category:@"Order_info_screen"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBOrderItemCell *cell;
    
    OrderItem *item = self.items[indexPath.row];
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
    
    [cell configureWithOrderItem:item];
    cell.panGestureRecognizer.delegate = self;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    OrderItem *item = self.items[indexPath.row];
    if(item.position.hasImage){
        return 100;
    } else {
        return  60;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 111.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *header = self.viewHeader;
    return header;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [GANHelper analyzeEvent:@"order_item_title_click" label:self.order.orderId category:@"Order_info_screen"];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

#pragma mark - DBOrderReturnViewDelegate

- (void)db_orderReturnView:(DBOrderReturnView *)view DidSelectCause:(DBOrderReturnCause)cause{
    [self cancelOrder];
    [self.returnCauseView hide];
}

- (void)db_orderReturnView:(DBOrderReturnView *)view DidSelectOtherCause:(NSString *)cause{
    [self cancelOrder];
    [self.returnCauseView hide];
}

- (void)db_orderReturnViewDidCancel:(DBOrderReturnView *)view{
    [self.returnCauseView hide];
}

@end
