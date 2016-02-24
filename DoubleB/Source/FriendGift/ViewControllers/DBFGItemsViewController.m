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
#import "DBBarButtonItem.h"

@interface DBFGItemsViewController ()<DBPositionCellDelegate>

@end

@implementation DBFGItemsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Подарки", nil);
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [UIView new];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCount) name:DBFriendGiftHelperNotificationItemsCount object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self updateCount];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateCount {
    self.navigationController.navigationBar.backItem.title = [NSString stringWithFormat:@"%ld %@", [[[DBFriendGiftHelper sharedInstance] itemsManager] totalCount], NSLocalizedString(@"п.", nil)];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[DBFriendGiftHelper sharedInstance].items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBPositionCell *cell;
    
    DBMenuPosition *position = [DBFriendGiftHelper sharedInstance].items[indexPath.row];
    if (position.hasImage){
        cell = [tableView dequeueReusableCellWithIdentifier:@"DBPositionCell"];
        if (!cell) {
            cell = [[DBPositionCell alloc] initWithType:DBPositionCellAppearanceTypeFull];
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"DBPositionCompactCell"];
        if (!cell) {
            cell = [[DBPositionCell alloc] initWithType:DBPositionCellAppearanceTypeCompact];
        }
    }
    
    cell.contentType = DBPositionCellContentTypeRegular;
    cell.priceAnimated = YES;
    [cell configureWithPosition:position];
    cell.delegate = self;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    DBMenuPosition *position = [DBFriendGiftHelper sharedInstance].items[indexPath.row];
    if(position.hasImage){
        return 120;
    } else {
        return 50;
    }
}


- (void)positionCellDidOrder:(id<PositionCellProtocol>)cell {
    [[DBFriendGiftHelper sharedInstance].itemsManager addPosition:[cell position]];
}

@end
