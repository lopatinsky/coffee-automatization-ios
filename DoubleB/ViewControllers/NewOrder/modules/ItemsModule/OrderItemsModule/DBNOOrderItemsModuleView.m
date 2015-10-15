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

@end
