//
//  DBNOBonusItemsModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 15/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBNOBonusItemsModuleView.h"
#import "OrderCoordinator.h"
#import "DBOrderItemCell.h"

#import "OrderItem.h"
#import "DBMenuPosition.h"

@implementation DBNOBonusItemsModuleView

- (ItemsManager *)manager {
    return [OrderCoordinator sharedInstance].bonusItemsManager;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
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
