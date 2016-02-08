//
//  DBCompaniesViewController.m
//  
//
//  Created by Balaban Alexander on 24/08/15.
//
//

#import "DBCompaniesViewController.h"
#import "AppDelegate.h"

#import "DBCompanyCell.h"

#import "DBServerAPI.h"
#import "DBCompanyInfo.h"
#import "DBCompaniesManager.h"

@interface DBCompaniesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *companies;

@property (weak, nonatomic) id<DBCompaniesViewControllerDelegate> delegate;
@property (nonatomic) DBCompaniesViewControllerMode mode;

@end

@implementation DBCompaniesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self db_setTitle:NSLocalizedString(@"Выберите ресторан", nil)];
    self.view.backgroundColor = [UIColor db_backgroundColor];
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 130.f;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.companies = [[DBCompaniesManager sharedInstance] companies];
    [self.tableView reloadData];
    
    if (self.companies.count == 0) {
        [self fetchCompanies:YES];
    } else {
        [self fetchCompanies:NO];
    }
}

- (void)fetchCompanies:(BOOL)animated {
    if (animated) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    [[DBCompaniesManager sharedInstance] requestCompanies:^(BOOL success, NSArray *companies) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (success) {
            self.companies = [[DBCompaniesManager sharedInstance] companies];
            [self.tableView reloadData];
            
            if (self.companies.count <= 1) {
                [self selectCompany:self.companies.firstObject];
            }
        }
    }];
}

- (void)setVCDelegate:(id<DBCompaniesViewControllerDelegate>)delegate {
    self.delegate = delegate;
}

- (void)setVCMode:(DBCompaniesViewControllerMode)mode {
    _mode = mode;
}

- (void)selectCompany:(DBCompany *)company {
    [[ApplicationManager sharedInstance] flushStoredCache];
    
    [DBCompaniesManager selectCompany:company];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[DBCompanyInfo sharedInstance] updateInfo:^(BOOL success) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (self.mode == DBCompaniesViewControllerModeChooseCompany) {
            if ([self.delegate respondsToSelector:@selector(db_companiesVC:didSelectCompany:)]) {
                [self.delegate db_companiesVC:self didSelectCompany:company];
            }
        } else {
            [[ApplicationManager sharedInstance] moveToMainState:YES];
        }
    }];
    [[DBCompanyInfo sharedInstance] fetchDependentInfo];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.companies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBCompanyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBCompanyCell"];
    
    if(!cell) {
        cell = [DBCompanyCell new];
    }
    
    DBCompany *company = self.companies[indexPath.row];
    [cell configure:company];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self selectCompany:self.companies[indexPath.row]];
}

#pragma mark - DBSettingsProtocol

+ (DBSettingsItem *)settingsItemForViewController:(UIViewController *)viewController {
    DBSettingsItem *settingsItem = [DBSettingsItem new];
    settingsItem.name = @"companiesVC";
    settingsItem.title = NSLocalizedString(@"Список ресторанов", nil);
    settingsItem.iconName = @"venue_gray";
    settingsItem.viewController = viewController;
    settingsItem.eventLabel = @"companies_click";
    settingsItem.navigationType = DBSettingsItemNavigationPush;
    return settingsItem;
}

+ (id<DBSettingsItemProtocol>)settingsItem {
    UIViewController<DBCompaniesViewControllerProtocol> *companiesVC = [DBCompaniesViewController new];
    [companiesVC setVCMode:DBCompaniesViewControllerModeChangeCompany];
    return [DBCompaniesViewController settingsItemForViewController:companiesVC];
}

- (id<DBSettingsItemProtocol>)settingsItem {
    [self setVCMode:DBCompaniesViewControllerModeChangeCompany];
    return [DBCompaniesViewController settingsItemForViewController:self];
}

@end

