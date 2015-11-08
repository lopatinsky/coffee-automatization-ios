//
//  DBCitiesViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBCitiesViewController.h"
#import "DBCityVariantCell.h"
#import "DBUnifiedMenuTableViewController.h"
#import "DBUnifiedAppManager.h"
#import "NetworkManager.h"

#import "MBProgressHUD.h"

@interface DBCitiesViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *cityView;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UITableView *citiesTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTableViewBottomAlignment;


@property (strong, nonatomic) NSArray *cities;
@end

@implementation DBCitiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self db_setTitle:NSLocalizedString(@"Выберите ваш город", nil)];
    
    self.citiesTableView.tableFooterView = [UIView new];
    self.citiesTableView.rowHeight = 44.f;
    self.citiesTableView.dataSource = self;
    self.citiesTableView.delegate = self;
    
    [self.cityTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    if (![[DBUnifiedAppManager sharedInstance] cities]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[DBUnifiedAppManager sharedInstance] fetchCities:^(BOOL success) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            [self reload];
        }];
    } else {
        [[DBUnifiedAppManager sharedInstance] fetchCities:nil];
        [self reload];
    }
    
    if ([DBUnifiedAppManager selectedCity]) {
        self.cityTextField.text = [DBUnifiedAppManager selectedCity].cityName;
        [self reload];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

//- (void)viewWillDisappear:(BOOL)animated {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}
//
//- (void)viewWillAppear:(BOOL)animated {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(citiesAreBecomeAvailable) name:kDBConcurrentOperationUnifiedCitiesLoadSuccess object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(citiesDownloadFailed) name:kDBConcurrentOperationUnifiedCitiesLoadFailure object:nil];
//    [[NetworkManager sharedManager] addPendingOperation:NetworkOperationFetchUnifiedCities];
//}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reload {
    _cities = [[DBUnifiedAppManager sharedInstance] cities:self.cityTextField.text];
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
    
    DBCity *city = _cities[indexPath.row];
    cell.city = city;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DBCity *city = _cities[indexPath.row];
    [DBUnifiedAppManager selectCity:city];
    
    [self.navigationController pushViewController:[DBUnifiedMenuTableViewController new] animated:YES];
}

- (void)textFieldDidChange:(UITextField *)sender {
    [self reload];
}

//
//#pragma mark - Networking
//- (void)citiesAreBecomeAvailable {
//    
//}
//
//- (void)citiesDownloadFailed {
//    
//}

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

@end
