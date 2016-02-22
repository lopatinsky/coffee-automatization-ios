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
#import "DBAAMenuViewController.h"

#import "DBUnifiedVenue.h"
#import "DBUnifiedPosition.h"
#import "OrderCoordinator.h"
#import "DBAPIClient.h"
#import "ApplicationManager.h"
#import "DBUnifiedAppManager.h"
#import "DBCompaniesManager.h"
#import "DBCitiesManager.h"
#import "NetworkManager.h"

#import "DBBarButtonItem.h"
#import "UIAlertView+BlocksKit.h"

@interface DBUnifiedMenuTableViewController() <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedController;
@property (weak, nonatomic) IBOutlet UIView *segmentHolderView;

@property (nonatomic, strong) NSArray<DBUnifiedPosition *> *positions;

@end

@implementation DBUnifiedMenuTableViewController

#pragma mark - Life-cycle
- (void)viewDidLoad {
    self.segmentedController.tintColor = [UIColor db_defaultColor];
    self.segmentedController.backgroundColor = [UIColor whiteColor];
    self.segmentedController.clipsToBounds = YES;
    self.segmentedController.layer.cornerRadius = 5.;
    
    [self.segmentedController setTitle:NSLocalizedString(@"Заведения", nil) forSegmentAtIndex:0];
    [self.segmentedController setTitle:NSLocalizedString(@"Кофе", nil) forSegmentAtIndex:1];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerNib:[UINib nibWithNibName:@"DBUnifiedMenuTableViewCell" bundle:nil] forCellReuseIdentifier:@"DBUnifiedMenuTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"DBUnifiedVenueTableViewCell" bundle:nil] forCellReuseIdentifier:@"DBUnifiedVenueTableViewCell"];
    
    self.segmentHolderView.hidden = self.type == UnifiedPosition;
    
    [self addObservers];
    [self setupInitial];
    [self fetchData];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.type == UnifiedPosition) {
        [self db_setTitle:[self.product objectForKey:@"title"]];
    } else {
        [self db_setTitle:[[DBCitiesManager selectedCity] cityName]];
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // dirty hack to handle layout on first launch
        [self.segmentHolderView layoutIfNeeded];
        [self.segmentHolderView setGradientWithColors:[NSArray arrayWithObjects:(id)[[UIColor grayColor] colorWithAlphaComponent:0.4].CGColor, (id)[UIColor clearColor].CGColor, nil]];
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Initialization
- (void)setupInitial {
    if (self.type != UnifiedPosition) {
        self.navigationItem.leftBarButtonItem = [DBBarButtonItem item:DBBarButtonTypeProfile handler:^{
            [self moveToSettings];
        }];
    }
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchMenuSuccess) name:kDBConcurrentOperationUnifiedMenuLoadSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchVenueSuccess) name:kDBConcurrentOperationUnifiedVenuesLoadSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchPositionsSuccess) name:kDBConcurrentOperationUnifiedPositionsLoadSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionFailure) name:kDBNetworkManagerConnectionFailed object:nil];
}

#pragma mark - Auixiliary
- (IBAction)segmentedControlValueChanged:(id)sender {
    if (self.segmentedController.selectedSegmentIndex == 0) {
        self.type = UnifiedVenue;
    } else {
        self.type = UnifiedMenu;
    }
    [self.tableView reloadData];
}

- (void)selectVenue:(DBUnifiedVenue *)venue {
    [Venue dropAllVenues];
    [Venue saveVenues:@[[venue venueObject]]];
    
    if (![[DBCompaniesManager selectedCompanyNamespace] isEqualToString:venue.company.companyNamespace]) {
        [[OrderCoordinator sharedInstance] flushCache];
        [[DBCompanyInfo sharedInstance] flushCache];
        [[DBMenu sharedInstance] clearMenu];
        [Order dropAllOrders];
        
        [DBCompaniesManager overrideCompanies:@[venue.company]];
        [DBCompaniesManager selectCompany:venue.company];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[DBCompanyInfo sharedInstance] updateInfo:^(BOOL success) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            [[DBCompanyInfo sharedInstance] fetchDependentInfo];
            
            DBAAMenuViewController *menuVC = [DBAAMenuViewController new];
            [self.navigationController pushViewController:menuVC animated:YES];
        }];
    } else {
        [[DBCompanyInfo sharedInstance] updateInfo:nil];
        [[DBCompanyInfo sharedInstance] fetchDependentInfo];
        
        DBAAMenuViewController *menuVC = [DBAAMenuViewController new];
        [self.navigationController pushViewController:menuVC animated:YES];
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (self.type) {
        case UnifiedVenue: {
            DBUnifiedVenue *unifiedVenue = [[[DBUnifiedAppManager sharedInstance] venues] objectAtIndex:indexPath.row];
            [self selectVenue:unifiedVenue];
            break;
        }
        case UnifiedMenu: {
            DBUnifiedMenuTableViewController *newVC = [DBUnifiedMenuTableViewController new];
            newVC.type = UnifiedPosition;
            newVC.product = [[[DBUnifiedAppManager sharedInstance] menu] objectAtIndex:indexPath.row];
            [self showViewController:newVC sender:nil];
            break;
        }
        case UnifiedPosition: {
            DBUnifiedVenue *unifiedVenue = [self.positions[indexPath.section] venue];
            DBMenuPosition *position = [self.positions[indexPath.section] positions][indexPath.row];
            [[OrderCoordinator sharedInstance].itemsManager addPosition:position];
            [self selectVenue:unifiedVenue];
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
            return [self.positions count];
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
            return [[[self.positions objectAtIndex:section] positions] count];
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
            [(DBUnifiedMenuTableViewCell *)cell setData:@{
                                                          @"position": [self.positions[indexPath.section] positions][indexPath.row],
                                                          @"venue_info": [self.positions[indexPath.section] venue]
                                                        }
                                               withType:self.type];
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

#pragma mark - Networking
- (void)fetchData {
    switch (self.type) {
        case UnifiedMenu: {
            [[NetworkManager sharedManager] addPendingOperation:NetworkOperationFetchUnifiedMenu];
            break;
        }
        case UnifiedVenue: {
            [[NetworkManager sharedManager] addPendingOperation:NetworkOperationFetchUnifiedVenues];
            break;
        }
        case UnifiedPosition: {
            [[NetworkManager sharedManager] addPendingOperation:NetworkOperationFetchUnifiedPositions withUserInfo:@{@"product_id": @([[self.product objectForKey:@"id"] integerValue])}];
            break;
        }
        default:
            break;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)fetchMenuSuccess {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if (self.type == UnifiedMenu) {
        [self.tableView reloadData];
    }
}

- (void)fetchVenueSuccess {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if (self.type == UnifiedVenue) {
        [self.tableView reloadData];
    }
}

- (void)fetchPositionsSuccess {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.positions = [[DBUnifiedAppManager sharedInstance] positionsForItem:@([[self.product objectForKey:@"id"] integerValue])];
    if (self.type == UnifiedPosition) {
        [self.tableView reloadData];
    }
}

- (void)connectionFailure {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Ошибка", nil) message:NSLocalizedString(@"Проверьте соединение с интернетом и попробуйте ещё раз", nil)
                          cancelButtonTitle:NSLocalizedString(@"Повторить", nil) otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                  [self fetchData];
                              });
                          }] show];
}


#pragma mark - Navigation
- (void)moveToSettings {
    DBBaseSettingsTableViewController *settingsController = [ViewControllerManager generalSettingsViewController];
    [self.navigationController pushViewController:settingsController animated:YES];
}

@end
