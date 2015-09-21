//
//  DBFriendGiftItemsModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 19/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBFGItemsModuleView.h"
#import "DBOrderItemCell.h"
#import "DBFriendGiftHelper.h"
#import "OrderItem.h"

@interface DBFGItemsModuleView ()<UITableViewDataSource, UIGestureRecognizerDelegate, DBOrderItemCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

@implementation DBFGItemsModuleView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBFGItemsModuleView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 60.f;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.separatorView.backgroundColor = [UIColor db_separatorColor];
}

- (void)reload {
    [super reload];
    [self.tableView reloadData];
}

- (CGSize)moduleViewContentSize {
    return CGSizeMake(self.frame.size.width, [DBFriendGiftHelper sharedInstance].itemsManager.totalCount * self.tableView.rowHeight);
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [DBFriendGiftHelper sharedInstance].itemsManager.totalCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBOrderItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBOrderItemCompactCell"];
    
    if (!cell) {
        cell = [[DBOrderItemCell alloc] initWithType:DBOrderItemCellTypeCompact];
        cell.delegate = self;
        cell.panGestureRecognizer.delegate = self;
    }
    
    OrderItem *item = [[DBFriendGiftHelper sharedInstance].itemsManager itemAtIndex:indexPath.row];
    
    cell.orderItem = item;
    [cell configure];
    
    return cell;
}


#pragma mark - DBOrderItemCellDelegate

- (BOOL)db_orderItemCellCanEdit:(DBOrderItemCell *)cell{
    return YES;
}

- (void)removeRowAtIndex:(NSInteger)index{
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                          withRowAnimation:UITableViewRowAnimationLeft];
    [self reload];
    [self.tableView endUpdates];
}

- (void)db_orderItemCellIncreaseItemCount:(DBOrderItemCell *)cell{
    NSInteger index = [self.tableView indexPathForCell:cell].row;
    [[DBFriendGiftHelper sharedInstance].itemsManager increaseOrderItemCountAtIndex:index];
    
    [cell reloadCount];
}

- (void)db_orderItemCellDecreaseItemCount:(DBOrderItemCell *)cell{
    NSInteger index = [self.tableView indexPathForCell:cell].row;
    NSInteger count = [[DBFriendGiftHelper sharedInstance].itemsManager decreaseOrderItemCountAtIndex:index];
    
    if(count == 0){
        [self removeRowAtIndex:index];
    } else {
        [cell reloadCount];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

@end
