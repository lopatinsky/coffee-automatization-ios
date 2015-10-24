//
//  DBShippingViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 22/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBShippingViewController.h"
#import "DBShippingAddressCell.h"
#import "DBPickerView.h"

#import "OrderCoordinator.h"

@interface DBShippingViewController ()<UITableViewDataSource, UITableViewDelegate, DBPickerViewDelegate, DBPopupViewComponentDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) DBPickerView *cityPickerView;

@end

@implementation DBShippingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self db_setTitle:NSLocalizedString(@"Доставка", nil)];
    self.view.backgroundColor = [UIColor db_backgroundColor];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [UIView new];
    
    self.cityPickerView = [DBPickerView new];
    self.cityPickerView.pickerDelegate = self;
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBShippingAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBShippingAddressCell"];
    
    if (!cell) {
        cell = [DBShippingAddressCell new];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [cell configureWithType:indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        self.cityPickerView.title = NSLocalizedString(@"Выберите город", nil);
        [self.cityPickerView configureWithItems:[DBCompanyInfo sharedInstance].deliveryCities];
        [self.cityPickerView showOnView:self.navigationController.view withAppearance:DBPopupViewComponentAppearanceModal];
    }
}

#pragma mark - DBPickerViewDelegate

- (void)db_pickerView:(DBPickerView *)view didSelectRow:(NSString *)row {
    [[OrderCoordinator sharedInstance].shippingManager setCity:row];
    [self.tableView reloadData];
    
    [GANHelper analyzeEvent:@"city_spinner_selected" label:row category:ADDRESS_SCREEN];
}

- (void)db_componentWillDismiss:(DBPopupViewComponent *)component {
    [self.tableView reloadData];
    
    [GANHelper analyzeEvent:@"city_spinner_closed" category:ADDRESS_SCREEN];
}

@end
