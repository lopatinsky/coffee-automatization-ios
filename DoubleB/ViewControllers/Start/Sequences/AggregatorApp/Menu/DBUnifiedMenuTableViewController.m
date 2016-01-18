//
//  DBUnifiedMenuTableViewController.m
//  DoubleB
//
//  Created by Balaban Alexander on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBUnifiedMenuTableViewController.h"
#import "DBUnifiedMenuTableViewCell.h"
#import "DBUnifiedVenueTableViewCell.h"

#import "OrderCoordinator.h"
#import "ApplicationManager.h"
#import "DBUnifiedAppManager.h"
#import "DBCitiesManager.h"
#import "NetworkManager.h"

@interface DBUnifiedMenuTableViewController() <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedController;
@property (weak, nonatomic) IBOutlet UIView *segmentHolderView;

@property (nonatomic, strong) NSArray *keys;

@end

@implementation DBUnifiedMenuTableViewController

- (void)viewDidLoad {
    self.segmentHolderView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.4];
    self.segmentedController.tintColor = [UIColor db_defaultColor];
    self.segmentedController.backgroundColor = [UIColor whiteColor];
    self.segmentedController.clipsToBounds = YES;
    self.segmentedController.layer.cornerRadius = 5.;
    
    [self.segmentedController setTitle:NSLocalizedString(@"Заведения", nil) forSegmentAtIndex:0];
    [self.segmentedController setTitle:NSLocalizedString(@"Кофе", nil) forSegmentAtIndex:1];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerNib:[UINib nibWithNibName:@"DBUnifiedMenuTableViewCell" bundle:nil] forCellReuseIdentifier:@"DBUnifiedMenuTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"DBUnifiedVenueTableViewCell" bundle:nil] forCellReuseIdentifier:@"DBUnifiedVenueTableViewCell"];
    
    if (self.type == UnifiedPosition) {
        [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        self.segmentedController.hidden = YES;
    } else {
        [self.tableView setContentInset:UIEdgeInsetsMake(40, 0, 0, 0)];
        self.segmentedController.hidden = NO;
    }
    
    [self db_setTitle:[[DBCitiesManager selectedCity] cityName]];
}

- (void)viewWillAppear:(BOOL)animated {
    switch (self.type) {
        case UnifiedMenu: {
            [[NetworkManager sharedManager] addPendingOperation:NetworkOperationFetchUnifiedMenu];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchMenuSuccess) name:kDBConcurrentOperationUnifiedMenuLoadSuccess object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchMenuFailure) name:kDBConcurrentOperationUnifiedMenuLoadFailure object:nil];
            break;
        }
        case UnifiedVenue: {
            [[NetworkManager sharedManager] addPendingOperation:NetworkOperationFetchUnifiedVenues];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchVenueSuccess) name:kDBConcurrentOperationUnifiedVenuesLoadSuccess object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchVenueFailure) name:kDBConcurrentOperationUnifiedVenuesLoadFailure object:nil];
            break;
        }
        case UnifiedPosition: {
            [[NetworkManager sharedManager] addPendingOperation:NetworkOperationFetchUnifiedPositions withUserInfo:@{@"product_id": @([[self.product objectForKey:@"id"] integerValue])}];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchPositionsSuccess) name:kDBConcurrentOperationUnifiedPositionsLoadSuccess object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchPositionsFailure) name:kDBConcurrentOperationUnifiedPositionsLoadFailure object:nil];
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

- (IBAction)segmentedControlValueChanged:(id)sender {
    if (self.segmentedController.selectedSegmentIndex == 0) {
        self.type = UnifiedVenue;
    } else {
        self.type = UnifiedMenu;
    }
    [self.tableView reloadData];
}

#pragma mark - Networking 
- (void)fetchMenuSuccess {
    if (self.type == UnifiedMenu) {
        [self.tableView reloadData];
    }
}

- (void)fetchMenuFailure {
    
}

- (void)fetchVenueSuccess {
    if (self.type == UnifiedVenue) {
        [self.tableView reloadData];
    }
}

- (void)fetchVenueFailure {
    
}

- (void)fetchPositionsSuccess {
    if (self.type == UnifiedPosition) {
        [self.tableView reloadData];
    }
}

- (void)fetchPositionsFailure {
    
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (self.type) {
        case UnifiedVenue: {
            [OrderCoordinator sharedInstance].orderManager.venue = [[[DBUnifiedAppManager sharedInstance] venues] objectAtIndex:indexPath.row];
            [[ApplicationManager sharedInstance] moveToScreen:ApplicationScreenMenu animated:YES];
            break;
        }
        case UnifiedMenu: {
            DBUnifiedMenuTableViewController *newVC = [DBUnifiedMenuTableViewController new];
            newVC.type = UnifiedPosition;
            newVC.product = [[[DBUnifiedAppManager sharedInstance] menu] objectAtIndex:indexPath.row];
            [self showViewController:newVC sender:nil];
            break;
        }
        default:
            break;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    switch (self.type) {
        case UnifiedMenu:
            return 1;
        case UnifiedPosition:
            return [self.keys count];
        case UnifiedVenue:
            return 1;
        default:
            return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (self.type) {
        case UnifiedMenu:
            return [[[DBUnifiedAppManager sharedInstance] menu] count];
        case UnifiedPosition:
            return [[[DBUnifiedAppManager sharedInstance] positionsForItem:@([[self.product objectForKey:@"id"] integerValue])] count];
        case UnifiedVenue:
            return [[[DBUnifiedAppManager sharedInstance] venues] count];
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    switch (self.type) {
        case UnifiedMenu: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"DBUnifiedMenuTableViewCell" forIndexPath:indexPath];
            [(DBUnifiedMenuTableViewCell *)cell setData:[[[DBUnifiedAppManager sharedInstance] menu] objectAtIndex:indexPath.row] withType:self.type];
            break;
        }
        case UnifiedPosition: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"DBUnifiedMenuTableViewCell" forIndexPath:indexPath];
            [(DBUnifiedMenuTableViewCell *)cell setData:[[[DBUnifiedAppManager sharedInstance] menu] objectAtIndex:indexPath.row] withType:self.type];
            break;
        }
        case UnifiedVenue: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"DBUnifiedVenueTableViewCell" forIndexPath:indexPath];
            [(DBUnifiedVenueTableViewCell *)cell setVenue:[[[DBUnifiedAppManager sharedInstance] venues] objectAtIndex:indexPath.row]];
            break;
        }
        default:
            return 0;
    }
    return cell;
}

@end
