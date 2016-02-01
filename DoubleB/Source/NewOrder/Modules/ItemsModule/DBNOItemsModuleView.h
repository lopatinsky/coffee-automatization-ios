//
//  DBNOItemsView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 15/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBModuleView.h"
#import "DBOrderItemCell.h"
#import "OrderItemsManager.h"

@interface DBNOItemsModuleView : DBModuleView <UITableViewDataSource, UITableViewDelegate, DBOrderItemCellDelegate>
@property (strong, nonatomic) UITableView *tableView;

- (ItemsManager *)manager;
@end
