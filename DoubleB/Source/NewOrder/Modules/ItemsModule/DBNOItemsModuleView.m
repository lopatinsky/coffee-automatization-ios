//
//  DBNOItemsView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 15/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBNOItemsModuleView.h"

#import "OrderItem.h"
#import "DBPromoManager.h"
#import "DBMenuPosition.h"

@interface DBNOItemsModuleView ()<UIGestureRecognizerDelegate>

@end

@implementation DBNOItemsModuleView

- (instancetype)init {
    self = [super init];
    
    self.tableView = [UITableView new];
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.tableView];
    [self.tableView alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self];
    
    return self;
}

- (ItemsManager *)manager {
    return nil;
}

#pragma mark - DBModuleView

- (void)reload:(BOOL)animated {
    [super reload:animated];
    [self.tableView reloadData];
}

- (CGFloat)moduleViewContentHeight{
    int height = 0;
    
    for(OrderItem *item in [self manager].items)
        if(item.position.hasImage){
            height += 100;
        } else {
            height += 60;
        }
    
    return height;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self manager].items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBOrderItemCell *cell;
    
    OrderItem *item = [[self manager] itemAtIndex:indexPath.row];
    if (item.position.hasImage){
        if(indexPath.section == 0)
            cell = [tableView dequeueReusableCellWithIdentifier:@"DBOrderItemCell"];
        
        if (!cell) {
            cell = [[DBOrderItemCell alloc] initWithType:DBOrderItemCellTypeFull];
        }
    } else {
        if(indexPath.section == 0)
            cell = [tableView dequeueReusableCellWithIdentifier:@"DBOrderItemCompactCell"];
        
        if (!cell) {
            cell = [[DBOrderItemCell alloc] initWithType:DBOrderItemCellTypeCompact];
        }
    }
    
    cell.delegate = self;
    cell.panGestureRecognizer.delegate = self;
    
    cell.orderItem = item;
    
    [cell configure];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    OrderItem *item = [[self manager] itemAtIndex:indexPath.row];
    
    if(item.position.hasImage){
        return 100;
    } else {
        return 60;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [[self manager] removeOrderItemAtIndex:indexPath.row];
    
    [self removeRowAtIndex:indexPath.row];
}

#pragma mark - DBOrderItemCellDelegate

- (BOOL)db_orderItemCellCanEdit:(DBOrderItemCell *)cell{
    return NO;
}

- (void)removeRowAtIndex:(NSInteger)index{
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                          withRowAnimation:UITableViewRowAnimationLeft];
    [self reload:YES];
    [self.tableView endUpdates];
}

- (void)db_orderItemCellIncreaseItemCount:(DBOrderItemCell *)cell{
    NSInteger index = [self.tableView indexPathForCell:cell].row;
    [[self manager] increaseOrderItemCountAtIndex:index];
    
    [cell reloadCount];
}

- (void)db_orderItemCellDecreaseItemCount:(DBOrderItemCell *)cell{
    NSInteger index = [self.tableView indexPathForCell:cell].row;
    NSInteger count = [[self manager] decreaseOrderItemCountAtIndex:index];
    
    if(count == 0){
        [self removeRowAtIndex:index];
    } else {
        [cell reloadCount];
    }
}

- (void)db_orderItemCellSwipe:(DBOrderItemCell *)cell{
}

- (void)db_orderItemCellDidSelect:(DBOrderItemCell *)cell{
}

- (void)db_orderItemCellDidSelectDelete:(DBOrderItemCell *)cell{
    NSInteger index = [self.tableView indexPathForCell:cell].row;
    [[self manager] removeOrderItemAtIndex:index];
    [self removeRowAtIndex:index];
    
    [GANHelper analyzeEvent:@"position_inactivity_view_delete_click"
                      label:cell.orderItem.position.positionId
                   category:self.analyticsCategory];
}

- (void)db_orderItemCellDidSelectReplace:(DBOrderItemCell *)cell{
    if(cell.promoItem.substitute){
        NSInteger index = [[self manager] replaceOrderItem:cell.orderItem withPosition:cell.promoItem.substitute];
        [cell.promoItem clear];
        
        if(index != -1){
            [self reload:YES];
        }
        [cell reload];
    }
    
    [GANHelper analyzeEvent:@"position_inactivity_view_replace_click"
                      label:cell.orderItem.position.positionId
                   category:self.analyticsCategory];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

@end
