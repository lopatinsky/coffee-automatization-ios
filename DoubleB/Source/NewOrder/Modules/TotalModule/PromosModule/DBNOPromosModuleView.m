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
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation DBNOPromosModuleView

- (void)commonInit {
    [super commonInit];
    
    self.backgroundColor = [UIColor clearColor];
    
    self.tableView.scrollEnabled = NO;
    [self.tableView setBackgroundColor:[UIColor db_backgroundColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.tableView];
    [self.tableView alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self];
    
    [[OrderCoordinator sharedInstance] addObserver:self withKeyPath:CoordinatorNotificationPromoUpdated selector:@selector(reload)];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self commonInit];
}

- (void)dealloc {
    [[OrderCoordinator sharedInstance] removeObserver:self];
}

- (void)reload:(BOOL)animated {
    [super reload:animated];
    
    [self.tableView reloadData];
}

- (CGFloat)moduleViewContentHeight {
    int height = 0;
    
    for (int i = 0; i < [OrderCoordinator sharedInstance].promoManager.promos.count; i++) {
        height += [self heightForRow:i];
    }
    
    return height;
}

- (CGFloat)heightForRow:(NSInteger)row {
    CGFloat h = [DBDiscountMessageCell labelHeight:[OrderCoordinator sharedInstance].promoManager.promos[row]] + 5;
    if (h < 25)
        h = 25.f;
    return h;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForRow:indexPath.row];
}

@end
