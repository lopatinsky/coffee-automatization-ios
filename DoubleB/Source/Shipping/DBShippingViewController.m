//
//  DBShippingViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 22/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBShippingViewController.h"
#import "DBShippingAddressCell.h"
#import "DBShippingAutocompleteView.h"
#import "DBPickerView.h"

#import "OrderCoordinator.h"

@interface DBShippingViewController ()<UITableViewDataSource, UITableViewDelegate, DBShippingAddressCellDelegate, DBPickerViewDelegate, DBPopupComponentDelegate, DBShippingAutocompleteViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintContentViewBottomAlignment;

@property (strong, nonatomic) DBShippingAddressCell *currentlyModifyingCell;
@property (strong, nonatomic) DBShippingAutocompleteView *autocompleteView;
@property (strong, nonatomic) DBPickerView *cityPickerView;

@end

@implementation DBShippingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self db_setTitle:NSLocalizedString(@"Доставка", nil)];
    self.view.backgroundColor = [UIColor db_backgroundColor];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [UIView new];
    
    self.autocompleteView = [DBShippingAutocompleteView new];
    self.autocompleteView.delegate = self;
    
    self.cityPickerView = [DBPickerView new];
    self.cityPickerView.pickerDelegate = self;
    
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)requestSuggestions:(DBShippingAddressCell *)cell {
    [[OrderCoordinator sharedInstance].shippingManager requestSuggestions:^(BOOL success) {
        if (success && self.currentlyModifyingCell.type == DBShippingAddressCellTypeStreet) {
            if ([OrderCoordinator sharedInstance].shippingManager.addressSuggestions.count > 0 && !self.autocompleteView.visible) {
                CGRect rect = [self.tableView convertRect:cell.frame toView:self.contentView];
                
                self.tableView.scrollEnabled = NO;
                [self.autocompleteView showOnView:self.contentView topOffset:rect.origin.y + rect.size.height];
            }
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBShippingAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBShippingAddressCell"];
    
    if (!cell) {
        cell = [DBShippingAddressCell new];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [cell configureWithType:indexPath.row];
    cell.editingEnabled = indexPath.row == DBShippingAddressCellTypeStreet;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self.view endEditing:YES];
        [self.autocompleteView hide];
        
        self.cityPickerView.title = NSLocalizedString(@"Выберите город", nil);
        [self.cityPickerView configureWithItems:[DBCompanyInfo sharedInstance].deliveryCities];
        [self.cityPickerView showOnView:self.navigationController.view appearance:DBPopupAppearanceModal transition:DBPopupTransitionBottom];
    }
}

#pragma mark - DBShippingAddressCellDelegate

- (void)db_addressCellStartEditing:(DBShippingAddressCell *)cell {
    if (cell.type == DBShippingAddressCellTypeStreet) {
        [self requestSuggestions:cell];
    }
    
    self.currentlyModifyingCell = cell;
}

- (void)db_addressCellEndEditing:(DBShippingAddressCell *)cell {
    [self.autocompleteView hide];
    
    self.currentlyModifyingCell = nil;
}

- (void)db_addressCell:(DBShippingAddressCell *)cell textChanged:(NSString *)text {
    if (cell.type == DBShippingAddressCellTypeStreet) {
        if (text.length > 0) {
            [self requestSuggestions:cell];
        } else {
            [self.autocompleteView hide];
        }
    }
}

- (BOOL)db_addressCellShouldClear:(DBShippingAddressCell *)cell {
    return cell.type == DBShippingAddressCellTypeStreet;
}

#pragma mark - DBShippingAutocompleteViewDelegate

- (void)db_shippingAutocompleteView:(DBShippingAutocompleteView *)view didSelectAddress:(DBShippingAddress *)address {
    [[OrderCoordinator sharedInstance].shippingManager setStreet:address.street];
    [self.tableView reloadData];
    [self.autocompleteView hide];
}

#pragma mark - DBPickerViewDelegate

- (void)db_pickerView:(DBPickerView *)view didSelectRow:(NSString *)row {
    [[OrderCoordinator sharedInstance].shippingManager setCity:row];
    [self.tableView reloadData];
    
    [GANHelper analyzeEvent:@"city_spinner_selected" label:row category:ADDRESS_SCREEN];
}

- (void)db_componentWillDismiss:(DBPopupComponent *)component {
    [self.tableView reloadData];
    
    [GANHelper analyzeEvent:@"city_spinner_closed" category:ADDRESS_SCREEN];
}

#pragma mark - Keyboard events

- (void)keyboardWillShow:(NSNotification *)notification{
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.constraintContentViewBottomAlignment.constant = keyboardRect.size.height;
                         [self.view layoutIfNeeded];
                     }
                     completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification{
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.constraintContentViewBottomAlignment.constant = 0;
                         [self.view layoutIfNeeded];
                     }
                     completion:nil];
}

@end
