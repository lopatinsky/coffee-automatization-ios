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
#import "DBModuleHeaderView.h"

@interface DBFGItemsModuleView ()<UITableViewDataSource, UIGestureRecognizerDelegate, DBOrderItemCellDelegate>

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *addView;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIImageView *addImage;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *consraintAddViewLeadingToSuperView;
@property (nonatomic) CGFloat initialAddViewWidth;

@end

@implementation DBFGItemsModuleView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBFGItemsModuleView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    DBModuleHeaderView *header = [DBModuleHeaderView new];
    header.title = NSLocalizedString(@"Выберите подарок", nil);
    header.translatesAutoresizingMaskIntoConstraints = NO;
    [self.headerView addSubview:header];
    [header alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self.headerView];
    
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 44.f;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollEnabled = NO;
    
    self.initialAddViewWidth = self.addView.frame.size.width;
    self.consraintAddViewLeadingToSuperView.constant = 0;
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
    
    [self.tableView reloadData];
    
    void (^block)() = ^void() {
        if([DBFriendGiftHelper sharedInstance].itemsManager.items.count == 0) {
            self.consraintAddViewLeadingToSuperView.constant = 0;
        } else {
            self.consraintAddViewLeadingToSuperView.constant = self.frame.size.width - self.initialAddViewWidth;
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
    int height = self.headerView.frame.size.height;
    int tableHeight = [DBFriendGiftHelper sharedInstance].itemsManager.items.count * self.tableView.rowHeight;
    height += tableHeight;
    
    if(tableHeight == 0) {
        height += 40;
    }
    
    return CGSizeMake(self.frame.size.width, height);
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [DBFriendGiftHelper sharedInstance].itemsManager.items.count;
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
    positionVC.parentNavigationController = self.ownerViewController.navigationController;
    [self.ownerViewController.navigationController pushViewController:positionVC animated:YES];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

@end
