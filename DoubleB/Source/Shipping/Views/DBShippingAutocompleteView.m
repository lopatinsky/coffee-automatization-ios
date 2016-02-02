//
//  DBShippingAutocompleteView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 30/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBShippingAutocompleteView.h"
#import "DBShippingAutocompleteCell.h"

#import "OrderCoordinator.h"

@interface DBShippingAutocompleteView()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@end

@implementation DBShippingAutocompleteView

- (instancetype)init {
    self = [super init];
    
    self.tableView = [UITableView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.tableView];
    [self.tableView alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self];
    
    [[OrderCoordinator sharedInstance] addObserver:self withKeyPath:CoordinatorNotificationAddressSuggestionsUpdated selector:@selector(reload)];
    
    return self;
}

- (void)dealloc {
    [[OrderCoordinator sharedInstance] removeObserver:self];
}

- (void)reload {
    [self.tableView reloadData];
}

- (void)showOnView:(UIView *)view topOffset:(NSInteger)offset {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:self];
    [self alignTop:[NSString stringWithFormat:@"%ld", (long)offset]
           leading:@"0" bottom:@"0" trailing:@"0" toView:view];
    [view layoutIfNeeded];
    
    self.backgroundColor = [UIColor db_backgroundColor];
    
    _visible = YES;
}

- (void)hide {
    [self removeFromSuperview];
    
    _visible = NO;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [OrderCoordinator sharedInstance].shippingManager.addressSuggestions.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBShippingAutocompleteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBShippingAutocompleteCell"];
    
    if (!cell) {
        cell = [DBShippingAutocompleteCell new];
    }
    
    DBShippingAddress *address = [OrderCoordinator sharedInstance].shippingManager.addressSuggestions[indexPath.row];
    [cell configureWithAddress:address];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DBShippingAddress *address = [OrderCoordinator sharedInstance].shippingManager.addressSuggestions[indexPath.row];
    
    if ([self.delegate respondsToSelector:@selector(db_shippingAutocompleteView:didSelectAddress:)]) {
        [self.delegate db_shippingAutocompleteView:self didSelectAddress:address];
    }
}

@end
