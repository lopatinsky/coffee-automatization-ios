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
#import "DBGeneralSettingsTableViewController.h"

#import "DBUnifiedVenue.h"
#import "OrderCoordinator.h"
#import "DBAPIClient.h"
#import "ApplicationManager.h"
#import "DBUnifiedAppManager.h"
#import "DBCompaniesManager.h"
#import "DBCitiesManager.h"
#import "NetworkManager.h"

#import "DBBarButtonItem.h"
#import "UIAlertView+BlocksKit.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface DBUnifiedMenuTableViewController() <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedController;
@property (weak, nonatomic) IBOutlet UIView *segmentHolderView;

@property (nonatomic, strong) NSArray *keys;

@end

@implementation DBUnifiedMenuTableViewController

- (void)viewDidLoad {
    [self.segmentHolderView setGradientWithColors:[NSArray arrayWithObjects:(id)[[UIColor grayColor] colorWithAlphaComponent:0.4].CGColor, (id)[UIColor clearColor].CGColor, nil]];
    self.segmentedController.tintColor = [UIColor db_defaultColor];
    self.segmentedController.backgroundColor = [UIColor whiteColor];
    self.segmentedController.clipsToBounds = YES;
    self.segmentedController.layer.cornerRadius = 5.;
    
    [self.segmentedController setTitle:NSLocalizedString(@"Заведения", nil) forSegmentAtIndex:0];
    [self.segmentedController setTitle:NSLocalizedString(@"Кофе", nil) forSegmentAtIndex:1];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerNib:[UINib nibWithNibName:@"DBUnifiedMenuTableViewCell" bundle:nil] forCellReuseIdentifier:@"DBUnifiedMenuTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"DBUnifiedVenueTableViewCell" bundle:nil] forCellReuseIdentifier:@"DBUnifiedVenueTableViewCell"];
    
    self.segmentedController.hidden = self.type == UnifiedPosition;
    
    [self setupInitial];
}

- (void)viewDidAppear:(BOOL)animated {
    [self db_setTitle:[[DBCitiesManager selectedCity] cityName]];
}

- (void)viewWillAppear:(BOOL)animated {
    [self db_setTitle:@""];
    [self.tableView reloadData];
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
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupInitial {
    self.navigationItem.leftBarButtonItem = [DBBarButtonItem item:DBBarButtonTypeProfile handler:^{
        [self moveToSettings];
    }];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}


- (NSArray *)mockData {
    return @[
             @{@"image": @"http://uashota.lg.ua/media/product/original/кофе%20латте%20макиато.jpg", @"name": @"Латте", @"info": @"14", @"price": @130},
             @{@"image": @"http://coffeegid.ru/wp-content/uploads/2014/12/vanilnyj-kapuchino-recept.jpg", @"name": @"Капучино", @"info": @"24", @"price": @80},
             @{@"image": @"http://kofe-inn.ru/wp-content/uploads/2015/07/американо.jpg", @"name": @"Американо", @"info": @"3", @"price": @110},
             @{@"image": @"http://express-f.ru/image/cache/data/Menu/kofe/good_4a83db8539f02-900x900.jpg", @"name": @"Эспрессо", @"info": @"21", @"price": @60},
            ];
}

- (void)moveToSettings {
    DBBaseSettingsTableViewController *settingsController = [ViewControllerManager generalSettingsViewController];
    [self.navigationController pushViewController:settingsController animated:YES];
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
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if (self.type == UnifiedMenu) {
        [self.tableView reloadData];
    }
}

- (void)fetchMenuFailure {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}

- (void)fetchVenueSuccess {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if (self.type == UnifiedVenue) {
        [self.tableView reloadData];
    }
}

- (void)fetchVenueFailure {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}

- (void)fetchPositionsSuccess {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if (self.type == UnifiedPosition) {
        [self.tableView reloadData];
    }
}

- (void)fetchPositionsFailure {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}

- (void)fetchCompanyInfo {
    [[DBCompanyInfo sharedInstance] updateInfo:^(BOOL success) {
        [[DBCompanyInfo sharedInstance] fetchDependentInfo];
        [[ApplicationManager sharedInstance] moveToScreen:ApplicationScreenMenu animated:YES];
    }];
   // [MBProgressHUD hideHUDForView:self.view animated:YES];
   // [[DBCompanyInfo sharedInstance] fetchDependentInfo];
   // [[ApplicationManager sharedInstance] moveToScreen:ApplicationScreenMenu animated:YES];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (self.type) {
        case UnifiedVenue: {
            DBUnifiedVenue *unifiedVenue = [[[DBUnifiedAppManager sharedInstance] venues] objectAtIndex:indexPath.row];
            [OrderCoordinator sharedInstance].orderManager.venue = [unifiedVenue venueObject];
            [DBCompaniesManager selectCompany:unifiedVenue.company];
            [[DBCompaniesManager sharedInstance] requestCompanies:^(BOOL success, NSArray *companies) {
                [DBCompaniesManager selectCompany:unifiedVenue.company];
            }];
            [self fetchCompanyInfo];
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

#pragma mark - DBSettingsProtocol

+ (id<DBSettingsItemProtocol>)settingsItem {
    DBUnifiedMenuTableViewController *unifiedVC = [DBUnifiedMenuTableViewController new];
    DBSettingsItem *settingsItem = [DBSettingsItem new];
    NSString *profileText = [[DBCompaniesManager selectedCompany] companyName];
    
    settingsItem.name = @"unifiedVC";
    settingsItem.title = NSLocalizedString(@"Профиль", nil);
    settingsItem.iconName = @"city_icon";
    settingsItem.viewController = unifiedVC;
    settingsItem.reachTitle = profileText && profileText.length ? profileText : nil;
    settingsItem.eventLabel = @"profile_click";
    settingsItem.navigationType = DBSettingsItemNavigationBlock;
    settingsItem.block = ^(UIViewController *vc) {
        [UIAlertView bk_showAlertViewWithTitle:@"Выход"
                                       message:@"При выходе в основное меню все данные корзины будут удалены. Продолжить?"
                             cancelButtonTitle:NSLocalizedString(@"Отмена", nil) otherButtonTitles:@[@"OK"]
                                       handler:^(UIAlertView *alertVчiew, NSInteger buttonIndex) {
                                           if (buttonIndex == 1) {
                                               [[ApplicationManager sharedInstance] flushCache];
                                               [[ApplicationManager sharedInstance] flushStoredCache];
                                               [[ApplicationManager sharedInstance] moveToScreen:ApplicationScreenUnified animated:YES];
                                           }
        }];
    };
    
    return settingsItem;
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

@end
