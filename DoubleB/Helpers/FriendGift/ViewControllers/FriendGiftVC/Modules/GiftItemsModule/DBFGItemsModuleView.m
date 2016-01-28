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
#import "DBMenuPosition.h"

#import "DBFGItemsViewController.h"
#import "DBModuleHeaderView.h"

@interface DBFGItemsModuleView ()<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, DBOrderItemCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *addView;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIImageView *addImage;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintAddViewWidth;
@property (nonatomic) CGFloat initialAddViewWidth;

@end

@implementation DBFGItemsModuleView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBFGItemsModuleView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollEnabled = NO;
    
    self.initialAddViewWidth = self.constraintAddViewWidth.constant;
    [self.addButton addTarget:self action:@selector(addButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.addImage templateImageWithName:@"gift_icon"];
    
    [[DBFriendGiftHelper sharedInstance] addObserver:self withKeyPath:DBFriendGiftHelperNotificationItemsPrice selector:@selector(reload)];
}

- (void)dealloc {
    [[DBFriendGiftHelper sharedInstance] removeObserver:self];
}

- (void)addButtonClick {
    DBFGItemsViewController *itemsVC = [DBFGItemsViewController new];
    [self.ownerViewController.navigationController pushViewController:itemsVC animated:YES];
}

- (void)reload:(BOOL)animated {
    [super reload:animated];
    
    if ([DBFriendGiftHelper sharedInstance].items.count == 1 && [DBFriendGiftHelper sharedInstance].itemsManager.items.count == 0) {
        [[DBFriendGiftHelper sharedInstance].itemsManager addPosition:[DBFriendGiftHelper sharedInstance].items.firstObject];
    }
    
    [self.tableView reloadData];
    
    void (^block)() = ^void() {
        if ([DBFriendGiftHelper sharedInstance].items.count < 2) {
            self.constraintAddViewWidth.constant = 0;
            self.constraintAddViewWidth.priority = 950;
        } else {
            if([DBFriendGiftHelper sharedInstance].itemsManager.items.count == 0) {
                self.constraintAddViewWidth.priority = 800;
            } else {
                self.constraintAddViewWidth.priority = 900;
            }
        }
        
        [self layoutIfNeeded];
    };
    
    if(animated) {
        [UIView animateWithDuration:0.5 animations:block];
    } else {
        block();
    }
}

- (CGSize)moduleViewContentSize {
    int height = 0;
    
    for (int i = 0; i < [DBFriendGiftHelper sharedInstance].itemsManager.items.count; i++) {
        height += [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    
    if(height == 0) {
        height += 40;
    }
    
    return CGSizeMake(self.frame.size.width, height);
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [DBFriendGiftHelper sharedInstance].itemsManager.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBOrderItemCell *cell;
    
    OrderItem *item = [[DBFriendGiftHelper sharedInstance].itemsManager itemAtIndex:indexPath.row];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderItem *item = [[DBFriendGiftHelper sharedInstance].itemsManager itemAtIndex:indexPath.row];
    
    if(item.position.hasImage){
        return 100;
    } else {
        return 60;
    }
}


#pragma mark - DBOrderItemCellDelegate

- (BOOL)db_orderItemCellCanEdit:(DBOrderItemCell *)cell {
    return [DBFriendGiftHelper sharedInstance].type == DBFriendGiftTypeCommon;
}

- (void)removeRowAtIndex:(NSInteger)index {
    [self.ownerViewController reloadAllModules];
}

- (void)db_orderItemCellIncreaseItemCount:(DBOrderItemCell *)cell{
    NSInteger index = [self.tableView indexPathForCell:cell].row;
    [[DBFriendGiftHelper sharedInstance].itemsManager increaseOrderItemCountAtIndex:index];
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

- (void)db_orderItemCellDidSelect:(DBOrderItemCell *)cell{
    OrderItem *item = cell.orderItem;
    
    UIViewController<PositionViewControllerProtocol> *positionVC = [[ViewControllerManager positionViewController] initWithPosition:item.position mode:PositionViewControllerModeOrderPosition];
    [self.ownerViewController.navigationController pushViewController:positionVC animated:YES];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

@end
