//
//  DBFGItemsViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 21/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBFGItemsViewController.h"
#import "DBPositionCell.h"
#import "DBMenuPosition.h"
#import "DBFriendGiftHelper.h"

@interface DBFGItemsViewController ()<DBPositionCellDelegate>

@end

@implementation DBFGItemsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Подарки", nil);
    
    self.tableView.rowHeight = 44.f;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [UIView new];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if([DBFriendGiftHelper sharedInstance].items.count == 0) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[DBFriendGiftHelper sharedInstance] fetchItems:^(BOOL success) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self.tableView reloadData];
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[DBFriendGiftHelper sharedInstance].items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBPositionCell *cell = [tableView dequeueReusableCellWithIdentifier:[DBPositionCell reuseIdentifierFor:DBPositionCellAppearanceTypeCompact]];
    
    if(!cell){
        cell = [[DBPositionCell alloc] initWithType:DBPositionCellAppearanceTypeCompact];
        cell.delegate = self;
        cell.priceAnimated = YES;
    }
    
    DBMenuPosition *position = [DBFriendGiftHelper sharedInstance].items[indexPath.row];
    [cell configureWithPosition:position];
    
    return cell;
}

-(void)positionCellDidOrder:(id<PositionCellProtocol>)cell {
    [[DBFriendGiftHelper sharedInstance].itemsManager addPosition:[cell position]];
}

@end
