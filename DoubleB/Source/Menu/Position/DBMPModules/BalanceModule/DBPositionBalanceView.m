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
#import "OrderCoordinator.h"
#import "Venue.h"

@interface DBPositionBalanceView ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeaderViewHeight;
@property (nonatomic) double initialHeaderViewHeight;


@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *label;
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
    self.label.text = NSLocalizedString(@"На данный момент этой позиции нет в наличии", nil);
    self.label.hidden = YES;
    
    self.initialHeaderViewHeight = self.constraintHeaderViewHeight.constant;
}

- (void)reload {
    if (!_balance) {
        [self reloadContent];
        
        self.tableView.hidden = YES;
        self.label.hidden = YES;
        self.activityIndicator.hidden = NO;
        
        [self.activityIndicator startAnimating];
        [[DBMenu sharedInstance] updatePositionBalance:self.position callback:^(BOOL success, NSArray *balance) {
            [self.activityIndicator stopAnimating];
            
            self.balance = balance;
            
            [self reloadContent];
        }];
    } else {
        [self reloadContent];
    }
}

- (void)reloadContent {
    if (_balance.count > 0) {
        self.tableView.hidden = NO;
        self.label.hidden = YES;
        [self.tableView reloadData];
    } else {
        self.tableView.hidden = YES;
        self.label.hidden = NO;
    }
    
    [self reloadHeader];
}

- (void)reloadHeader {
    if (_mode == DBPositionBalanceViewModeBalance) {
        self.constraintHeaderViewHeight.constant = 0;
        self.headerView.hidden = YES;
    } else {
        self.constraintHeaderViewHeight.constant = self.initialHeaderViewHeight;
        self.headerView.hidden = NO;
        
        if (![OrderCoordinator sharedInstance].orderManager.venue) {
            self.headerLabel.text = NSLocalizedString(@"Пожалуйста, выберите магазин для оформления заказа", nil);
        } else {
            NSString *text = [NSString stringWithFormat:@"Данная позиция сейчас недоступна в магазине \"%@\", Вы можете выбрать другой магазин для оформления заказа", [OrderCoordinator sharedInstance].orderManager.venue.title];
            NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:text];
            [attrText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.f] range:[text rangeOfString:[OrderCoordinator sharedInstance].orderManager.venue.title]];
            self.headerLabel.attributedText = attrText;
        }
    }
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.balance.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBPositionBalanceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBPositionBalanceCell"];
    
    if (!cell) {
        cell = [DBPositionBalanceCell new];
    }
    
    DBMenuPositionBalance *balance = self.balance[indexPath.row];
    [cell configure:balance];
    cell.tickAvailable = _mode == DBPositionBalanceViewModeChooseVenue;
    cell.tickSelected = balance.venue == [OrderCoordinator sharedInstance].orderManager.venue;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DBMenuPositionBalance *balance = self.balance[indexPath.row];
    if (_mode == DBPositionBalanceViewModeChooseVenue) {
        if (_venueSelectedBlock) {
            _venueSelectedBlock(balance.venue);
        }
        
        [self.popupViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - DBPopupViewControllerContent

- (CGFloat)db_popupContentContentHeight {
    return 400.f;
}


@end
