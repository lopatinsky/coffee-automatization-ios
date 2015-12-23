//
//  DBPositionBalanceViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 30/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBPositionBalanceView.h"
#import "DBPositionBalanceCell.h"

#import "DBMenu.h"

@interface DBPositionBalanceView ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *label;

@property (strong, nonatomic) NSArray *balances;
@end

@implementation DBPositionBalanceView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBPositionBalanceView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 40.f;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.activityIndicator.hidesWhenStopped = YES;
}

- (void)reload {
    self.tableView.hidden = YES;
    self.label.hidden = YES;
    self.activityIndicator.hidden = NO;
    
    [self.activityIndicator startAnimating];
    [[DBMenu sharedInstance] updatePositionBalance:self.position callback:^(BOOL success, NSArray *balance) {
        [self.activityIndicator stopAnimating];
        
        self.balances = balance;
        
        if (self.balances.count > 0) {
            self.tableView.hidden = NO;
            self.label.hidden = YES;
            [self.tableView reloadData];
        } else {
            self.tableView.hidden = YES;
            self.label.hidden = NO;
        }
    }];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.balances.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBPositionBalanceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBPositionBalanceCell"];
    
    if (!cell) {
        cell = [DBPositionBalanceCell new];
    }
    
    [cell configure:self.balances[indexPath.row]];
    
    return cell;
}

#pragma mark - DBPopupViewControllerContent

- (CGFloat)db_popupContentContentHeight {
    return 400.f;
}


@end
