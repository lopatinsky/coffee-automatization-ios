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
#import "DBTabBarController.h"
#import "LaunchViewController.h"
#import "DBCompaniesManager.h"

@interface DBCompaniesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIView *titleView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *titleViewHeightConstraint;
@property (strong, nonatomic) IBOutlet UIImageView *splashImageView;

@property (strong, nonatomic) NSArray *companies;

@end

@implementation DBCompaniesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    [self initializeViews];
    [self requestCompanies];
}

- (void)initializeViews {
    if (self.firstLaunch) {
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
    
    if (self.firstLaunch) {
        self.splashImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"launch_%d.png", (int)[[UIScreen mainScreen] bounds].size.height]];
    }
}

- (void)requestCompanies {
    self.companies = [[DBCompaniesManager sharedInstance] companies];
    [self.tableView reloadData];
    if (self.companies.count == 1) {
        [self putSelectedNamespace:self.companies[0]];
    } else {
        self.splashImageView.hidden = YES;
    }
}

- (void)putSelectedNamespace:(NSString *)namespace {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self preloadData];
    if ([DBCompanyInfo sharedInstance].deliveryTypes) {
        delegate.window.rootViewController = [LaunchViewController new];
    } else {
        delegate.window.rootViewController = [DBTabBarController sharedInstance];
    }
}

- (void)preloadData {
    [[ApplicationManager sharedInstance] flushStoredCache];
    [[ApplicationManager sharedInstance] updateAllInfo:nil];
    [[DBTabBarController sharedInstance] moveToStartState];
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

