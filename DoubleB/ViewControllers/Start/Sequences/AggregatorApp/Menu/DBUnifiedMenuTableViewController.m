//
//  DBUnifiedMenuTableViewController.m
//  DoubleB
//
//  Created by Balaban Alexander on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBUnifiedMenuTableViewController.h"
#import "DBUnifiedMenuTableViewCell.h"

#import "DBUnifiedAppManager.h"
#import "NetworkManager.h"

@interface DBUnifiedMenuTableViewController() <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *keys;

@end

@implementation DBUnifiedMenuTableViewController

- (void)viewDidLoad {
    if (!self.data) {
        self.data = [NSMutableDictionary new];
    }
    
    switch (self.type) {
        case UnifiedMenu:
            self.data[@"positions"] = [[DBUnifiedAppManager sharedInstance] allPositions];
            break;
        case UnifiedPosition:
            self.data[@"available_positions"] = [[DBUnifiedAppManager sharedInstance] positionsForItem:self.data[@"product_id"]];
            self.keys = [self.data[@"available_positions"] allKeys];
            break;
        default:
            break;
    }
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerNib:[UINib nibWithNibName:@"DBUnifiedMenuTableViewCell" bundle:nil] forCellReuseIdentifier:@"DBUnifiedMenuTableViewCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    switch (self.type) {
        case UnifiedMenu: {
            [[NetworkManager sharedManager] addUniqueOperation:NetworkOperationFetchUnifiedMenu];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuIsAvailable) name:kDBConcurrentOperationUnifiedMenuLoadSuccess object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuIsAvailable) name:kDBConcurrentOperationUnifiedMenuLoadFailure object:nil];
            break;
        }
        case UnifiedPosition: {
            [[NetworkManager sharedManager] addUniqueOperation:NetworkOperationFetchUnifiedPositions withUserInfo:@{@"product_id": self.data[@"product_id"]}];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(positionsAreAvailable) name:kDBConcurrentOperationUnifiedPositionsLoadSuccess object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(positionsDownloadFailed) name:kDBConcurrentOperationUnifiedPositionsLoadFailure object:nil];
            break;
        }
        default:
            break;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSArray *)mockData {
    return @[
             @{@"image": @"http://uashota.lg.ua/media/product/original/кофе%20латте%20макиато.jpg", @"name": @"Латте", @"info": @"14", @"price": @130},
             @{@"image": @"http://coffeegid.ru/wp-content/uploads/2014/12/vanilnyj-kapuchino-recept.jpg", @"name": @"Капучино", @"info": @"24", @"price": @80},
             @{@"image": @"http://kofe-inn.ru/wp-content/uploads/2015/07/американо.jpg", @"name": @"Американо", @"info": @"3", @"price": @110},
             @{@"image": @"http://express-f.ru/image/cache/data/Menu/kofe/good_4a83db8539f02-900x900.jpg", @"name": @"Эспрессо", @"info": @"21", @"price": @60},
            ];
}

#pragma mark - Networking 
- (void)menuIsAvailable {
    switch (self.type) {
        case UnifiedMenu:
            self.data[@"positions"] = [[DBUnifiedAppManager sharedInstance] allPositions];
            break;
        case UnifiedPosition:
            self.data[@"available_positions"] = [[DBUnifiedAppManager sharedInstance] positionsForItem:self.data[@"product_id"]];
            self.keys = [self.data[@"available_positions"] allKeys];
            break;
        default:
            break;
    }
    [self.tableView reloadData];
}

- (void)menuDownloadFailed {
    // analtics about fail
}

- (void)positionsAreAvailable {
    
}

- (void)positionsDownloadFailed {
    
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DBUnifiedMenuTableViewController *viewController = [DBUnifiedMenuTableViewController new];
    viewController.data = [NSMutableDictionary  dictionaryWithDictionary:@{@"product_id": self.data[@"positions"][indexPath.row][@"id"]}];
    viewController.type = UnifiedPosition;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    switch (self.type) {
        case UnifiedMenu:
            return 1;
        case UnifiedPosition:
            return [self.keys count];
        default:
            return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    switch (self.type) {
        case UnifiedMenu:
            return [[UIView alloc] initWithFrame:CGRectZero];
        case UnifiedPosition: {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
            [label setFont:[UIFont boldSystemFontOfSize:12]];
            NSString *string = [self.data[@"available_positions"] allKeys][section];
            [label setText:string];
            [view addSubview:label];
            [view setBackgroundColor:[UIColor colorWithRed:166/255.0 green:177/255.0 blue:186/255.0 alpha:1.0]];
            return view;
        }
        default:
            return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (self.type) {
        case UnifiedMenu:
            return [self.data[@"positions"] count];
        case UnifiedPosition:
            return [self.data[@"available_positions"][self.keys[section]][@"items"] count];
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBUnifiedMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBUnifiedMenuTableViewCell" forIndexPath:indexPath];
    
    switch (self.type) {
        case UnifiedMenu:
            [cell setData:self.data[@"positions"][indexPath.row] withType:self.type];
            break;
        case UnifiedPosition:
            [cell setData:self.data[@"available_positions"][self.keys[indexPath.section]][@"items"][indexPath.row] withType:self.type];
            break;
        default:
            return 0;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

@end
