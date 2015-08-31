//
//  DBCompaniesViewController.m
//  
//
//  Created by Balaban Alexander on 24/08/15.
//
//

#import "DBCompaniesViewController.h"
#import "AppDelegate.h"

#import "DBServerAPI.h"
#import "DBCompanyInfo.h"
#import "MBProgressHUD.h"
#import "DBCompaniesManager.h"

@interface DBCompaniesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIView *titleView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *titleViewHeightConstraint;

@property (strong, nonatomic) NSArray *companies;

@end

@implementation DBCompaniesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    [self initializeViews];
    
    self.companies = [[DBCompaniesManager sharedInstance] companies];
}

- (void)initializeViews {
    if (self.mode == DBCompaniesViewControllerModeChangeCompany) {
        self.titleView.hidden = false;
        self.titleView.backgroundColor = [UIColor db_defaultColor];
    } else {
        self.titleView.hidden = true;
        self.titleViewHeightConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.titleLabel.text = NSLocalizedString(@"Выберите ресторан", nil);
    self.titleLabel.textColor = [UIColor whiteColor];
    
    self.title = NSLocalizedString(@"Выберите ресторан", nil);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
}

- (void)putSelectedNamespace:(NSString *)namespace {
    [[ApplicationManager sharedInstance] flushStoredCache];
    [DBCompaniesManager selectCompanyName:namespace];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[DBCompanyInfo sharedInstance] updateInfo:^(BOOL success) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if(success){
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            delegate.window.rootViewController = [ViewControllerManager mainViewController];
        } else {
            [self showError:@"Не удалось загрузить информацию о выбранное компании"];
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.companies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    cell.textLabel.text = [self.companies[indexPath.row] objectForKey:@"name"];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self putSelectedNamespace:[self.companies[indexPath.row] objectForKey:@"namespace"]];
}

@end

