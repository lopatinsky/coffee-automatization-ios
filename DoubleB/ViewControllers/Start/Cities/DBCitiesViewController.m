//
//  DBCitiesViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBCitiesViewController.h"
#import "DBCityVariantCell.h"
#import "DBGeneralSettingsTableViewController.h"
#import "DBUnifiedMenuTableViewController.h"
#import "DBCitiesManager.h"
#import "NetworkManager.h"
#import "DBCompaniesManager.h"
#import "DBCompaniesViewController.h"

#import "MBProgressHUD.h"

@interface DBCitiesViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *citiesTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTableViewBottomAlignment;


@property (strong, nonatomic) NSArray *cities;
@end

@implementation DBCitiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self db_setTitle:NSLocalizedString(@"Выберите ваш город", nil)];
    self.view.backgroundColor = [UIColor db_backgroundColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.citiesTableView.tableFooterView = [UIView new];
    self.citiesTableView.backgroundColor = [UIColor clearColor];
    self.citiesTableView.rowHeight = 44.f;
    self.citiesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.citiesTableView.dataSource = self;
    self.citiesTableView.delegate = self;
    
    self.searchBar.delegate = self;
    
    if (![[DBCitiesManager sharedInstance] cities]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[DBCitiesManager sharedInstance] fetchCities:^(BOOL success) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            [self reload];
        }];
    } else {
        [[DBCitiesManager sharedInstance] fetchCities:^(BOOL success) {
            [self reload];
        }];
    }
    
    if ([DBCitiesManager selectedCity] && self.mode == DBCitiesViewControllerModeChooseCity) {
        self.searchBar.text = [DBCitiesManager selectedCity].cityName;
    }
    
    [self reload];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reload {
    _cities = [[DBCitiesManager sharedInstance] cities:self.searchBar.text];
    [self.citiesTableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBCityVariantCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBCityVariantCell"];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DBCityVariantCell" owner:self options:nil] firstObject];
    }
    
    DBUnifiedCity *city = _cities[indexPath.row];
    cell.city = city;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.mode == DBCitiesViewControllerModeChooseCity) {
        if ([self.delegate respondsToSelector:@selector(db_citiesViewControllerDidSelectCity:)]) {
            [self.delegate db_citiesViewControllerDidSelectCity:_cities[indexPath.row]];
        }
    } else {
        // REALY REALY DIRTY
        [[ApplicationManager sharedInstance] flushStoredCache];
        
        [DBCitiesManager selectCity:_cities[indexPath.row]];
        if ([ApplicationConfig sharedInstance].hasCompanies) {
            [[DBCompaniesManager sharedInstance] requestCompanies:^(BOOL success, NSArray *companies) {
                if (companies.count > 1) {
                    DBCompaniesViewController *companiesVC = [DBCompaniesViewController new];
                    [companiesVC setVCMode:DBCompaniesViewControllerModeChangeCompany];
                } else {
                    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    [[DBCompanyInfo sharedInstance] updateInfo:^(BOOL success) {
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        
                        [[ApplicationManager sharedInstance] moveToScreen:ApplicationScreenRoot animated:YES];
                    }];
                    [[ApplicationManager sharedInstance] fetchCompanyDependentInfo];
                }
            }];
        } else {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[DBCompanyInfo sharedInstance] updateInfo:^(BOOL success) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                
                [[ApplicationManager sharedInstance] moveToScreen:ApplicationScreenRoot animated:YES];
            }];
            [[ApplicationManager sharedInstance] fetchCompanyDependentInfo];
        }
    }
}


#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
     [self reload];
}

#pragma mark - Keyboard events

- (void)keyboardWillShow:(NSNotification *)notification{
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.constraintTableViewBottomAlignment.constant = -keyboardRect.size.height;
                         [self.view layoutIfNeeded];
                     }
                     completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification{
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.constraintTableViewBottomAlignment.constant = 0;
                         [self.view layoutIfNeeded];
                     }
                     completion:nil];
}

#pragma mark - DBSettignsProtocol

+ (id<DBSettingsItemProtocol>)settingsItem {
    DBCitiesViewController *vc = [DBCitiesViewController new];
    vc.mode = DBCitiesViewControllerModeChangeCity;
    DBSettingsItem *settingsItem = [DBSettingsItem new];
    
    settingsItem.name = @"citiesVC";
    settingsItem.title = NSLocalizedString(@"Город", nil);
    settingsItem.iconName = @"city_icon";
    settingsItem.viewController = vc;
    settingsItem.reachTitle = [[DBCitiesManager selectedCity] cityName];
    settingsItem.eventLabel = @"cities_click";
    settingsItem.navigationType = DBSettingsItemNavigationPush;
    
    return settingsItem;
}

@end
