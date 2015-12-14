//
//  DBNOOrderItemsModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 15/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBNOOrderItemsModuleView.h"
#import "OrderCoordinator.h"

#import "DBPromoManager.h"
#import "OrderItem.h"
#import "DBMenuPosition.h"

@implementation DBNOOrderItemsModuleView

- (instancetype)init {
    self = [super init];
    
    [[OrderCoordinator sharedInstance] addObserver:self withKeyPath:CoordinatorNotificationPromoUpdated selector:@selector(reloadItemsErrors)];
    
    return self;
}

- (void)dealloc {
    [[OrderCoordinator sharedInstance] removeObserver:self];
}

- (ItemsManager *)manager {
    return [OrderCoordinator sharedInstance].itemsManager;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBOrderItemCell *cell = (DBOrderItemCell*)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    DBPromoItem *promoItem = [[OrderCoordinator sharedInstance].promoManager promosForOrderItem:cell.orderItem];
    cell.promoItem = promoItem;
    [cell configure];
    
    return cell;
}

- (BOOL)db_orderItemCellCanEdit:(DBOrderItemCell *)cell{
    return YES;
}

- (void)db_orderItemCellDidSelect:(DBOrderItemCell *)cell{
    OrderItem *item = cell.orderItem;
    
    UIViewController<PositionViewControllerProtocol> *positionVC = [[ViewControllerManager positionViewController] initWithPosition:item.position mode:PositionViewControllerModeOrderPosition];
    positionVC.parentNavigationController = self.ownerViewController.navigationController;
    positionVC.hidesBottomBarWhenPushed = YES;
    [self.ownerViewController.navigationController pushViewController:positionVC animated:YES];
}

- (void)reloadItemsErrors {
    for (int i = 0; i < [self manager].items.count; i++) {
        OrderItem *orderItem = [self manager].items[i];
        DBPromoItem *promoItem = [[OrderCoordinator sharedInstance].promoManager promosForOrderItem:orderItem];
        
        if (promoItem.errors > 0) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

@end
