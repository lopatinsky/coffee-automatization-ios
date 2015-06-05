//
//  DBPromosListViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 02.06.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBPromosListViewController.h"
#import "DBPromoCell.h"
#import "DBPromoManager.h"
#import "DBPromoManager.h"

#import "MBProgressHUD.h"

@interface DBPromosListViewController ()

@end

@implementation DBPromosListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Список акций", nil);
    self.view.backgroundColor = [UIColor db_backgroundColor];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.rowHeight = 100;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [GANHelper analyzeScreen:PROMOS_LIST_SCREEN];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[DBPromoManager sharedManager].promotionList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBPromoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBPromoCell"];
    
    if(!cell){
        cell = [DBPromoCell new];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    DBPromotion *promotion = [DBPromoManager sharedManager].promotionList[indexPath.row];
    cell.titleLabel.text = promotion.promotionName;
    cell.descriptionLabel.text = promotion.promotionDescription;
    
    return cell;
}

@end
