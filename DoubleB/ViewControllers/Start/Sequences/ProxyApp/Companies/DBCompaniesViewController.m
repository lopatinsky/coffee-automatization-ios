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
#import "MBProgressHUD.h"
#import "DBCompaniesManager.h"

@interface DBCompaniesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *companies;

@property (nonatomic, copy) void(^block)();

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
}

- (void)setFinalBlock:(void (^)())finalBlock {
    self.block = finalBlock;
}

- (void)selectCompany:(DBCompany *)company {
    [DBCompaniesManager selectCompany:company];
    
    if (self.block) {
        self.block();
    }
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

@end

