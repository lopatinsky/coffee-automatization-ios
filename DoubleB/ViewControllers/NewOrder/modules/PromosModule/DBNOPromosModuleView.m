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

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBNOPromosModuleView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.tableView.scrollEnabled = NO;
    self.tableView.backgroundColor = [UIColor db_backgroundColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [[OrderCoordinator sharedInstance] addObserver:self withKeyPath:CoordinatorNotificationPromoUpdated selector:@selector(reload)];
}

- (void)dealloc {
    [[OrderCoordinator sharedInstance] removeObserver:self];
}

- (void)reload:(BOOL)animated {
    [super reload:animated];
    
    [self.tableView reloadData];
}

- (CGSize)moduleViewContentSize {
    double height = [OrderCoordinator sharedInstance].promoManager.promos.count * 44.f;
    
    return CGSizeMake(self.frame.size.width, height);
}

#pragma mark UITableViewDelegate

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
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
        
        cell.messageLabel.textColor = [UIColor db_defaultColor];
        cell.messageLabel.textAlignment = NSTextAlignmentRight;
    }
    
    cell.messageLabel.text = [OrderCoordinator sharedInstance].promoManager.promos[indexPath.row];
    
    return cell;
}

@end
