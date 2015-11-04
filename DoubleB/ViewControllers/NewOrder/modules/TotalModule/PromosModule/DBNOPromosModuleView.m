//
//  DBNOPromosModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 17/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBNOPromosModuleView.h"
#import "DBDiscountMessageCell.h"

#import "OrderCoordinator.h"

@interface DBNOPromosModuleView ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@end

@implementation DBNOPromosModuleView

- (void)commonInit {
    [super commonInit];
    
    self.backgroundColor = [UIColor clearColor];
    
    self.tableView = [UITableView new];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.tableView];
    [self.tableView alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self];
    
    self.tableView.scrollEnabled = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 25.f;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [[OrderCoordinator sharedInstance] addObserver:self withKeyPath:CoordinatorNotificationPromoUpdated selector:@selector(reload)];
}

- (void)dealloc {
    [[OrderCoordinator sharedInstance] removeObserver:self];
}

- (void)reload:(BOOL)animated {
    [super reload:animated];
    
    [self.tableView reloadData];
}

- (CGFloat)moduleViewContentHeight {
    double height = [OrderCoordinator sharedInstance].promoManager.promos.count * self.tableView.rowHeight;
    
    return height;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[OrderCoordinator sharedInstance].promoManager.promos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBDiscountMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBDiscountMessageCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DBDiscountMessageCell" owner:self options:nil] firstObject];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.messageLabel.text = [OrderCoordinator sharedInstance].promoManager.promos[indexPath.row];
    
    return cell;
}

@end
