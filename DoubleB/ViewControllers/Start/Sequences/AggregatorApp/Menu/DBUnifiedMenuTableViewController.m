//
//  DBUnifiedMenuTableViewController.m
//  DoubleB
//
//  Created by Balaban Alexander on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBUnifiedMenuTableViewController.h"
#import "DBUnifiedMenuTableViewCell.h"

#import "NetworkManager.h"

@interface DBUnifiedMenuTableViewController() <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DBUnifiedMenuTableViewController

- (void)viewDidLoad {
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerNib:[UINib nibWithNibName:@"DBUnifiedMenuTableViewCell" bundle:nil] forCellReuseIdentifier:@"DBUnifiedMenuTableViewCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [[NetworkManager sharedManager] addUniqueOperation:NetworkOperationFetchUnifiedMenu];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuIsAvailable) name:kDBConcurrentOperationUnifiedMenuLoadSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuIsAvailable) name:kDBConcurrentOperationUnifiedMenuLoadFailure object:nil];
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
    
}

- (void)menuDownloadFailed {
    
}

#pragma mark - UITableViewDelegate


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self mockData] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBUnifiedMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBUnifiedMenuTableViewCell" forIndexPath:indexPath];
    
    [cell setData:[self mockData][indexPath.row]];
    
    return cell;
}

@end
