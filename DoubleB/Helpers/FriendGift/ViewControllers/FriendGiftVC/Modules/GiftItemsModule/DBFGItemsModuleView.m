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

#import "DBFGItemsViewController.h"

@interface DBFGItemsModuleView ()<UITableViewDataSource, UIGestureRecognizerDelegate, DBOrderItemCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UIButton *addButton;

@end

@implementation DBFGItemsModuleView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBFGItemsModuleView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 60.f;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.addButton setTitleColor:[UIColor db_defaultColor] forState:UIControlStateNormal];
    [self.addButton setTitle:NSLocalizedString(@"Выбери подарок", nil) forState:UIControlStateNormal];
    [self.addButton addTarget:self action:@selector(addButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.separatorView.backgroundColor = [UIColor db_separatorColor];
}

- (void)addButtonClick {
    DBFGItemsViewController *itemsVC = [DBFGItemsViewController new];
    [self.ownerViewController.navigationController pushViewController:itemsVC animated:YES];
}

- (void)reload:(BOOL)animated {
    [super reload:animated];
    [self.tableView reloadData];
    [self setNeedsLayout];
}

- (CGSize)moduleViewContentSize {
    int height = self.frame.size.height - self.tableView.frame.size.height;
    height += [DBFriendGiftHelper sharedInstance].itemsManager.totalCount * self.tableView.rowHeight;
    return CGSizeMake(self.frame.size.width, height);
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
