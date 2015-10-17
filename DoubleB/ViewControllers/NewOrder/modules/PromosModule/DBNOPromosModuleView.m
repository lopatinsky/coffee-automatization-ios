//
//  DBNOPromosModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 17/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBNOPromosModuleView.h"

@interface DBNOPromosModuleView ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *messages;
@end

@implementation DBNOPromosModuleView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBNOPromosModuleView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    self.tableView.scrollEnabled = NO;
    self.tableView.backgroundColor = [UIColor db_backgroundColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)reload:(BOOL)animated {
    [super reload:animated];
    
    [self.tableView reloadData];
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
    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBDiscountMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBDiscountMessageCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DBDiscountMessageCell" owner:self options:nil] firstObject];
    }
    
    cell.messageLabel.text = self.messages[indexPath.row];
    
    if (self.currentlyShowPromos) {
        cell.messageLabel.textColor = [UIColor db_defaultColor];
        cell.messageLabel.textAlignment = NSTextAlignmentRight;
    } else {
        cell.messageLabel.textColor = [UIColor orangeColor];
        cell.messageLabel.textAlignment = NSTextAlignmentLeft;
        [cell.messageLabel db_startObservingAnimationNotification];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

@end
