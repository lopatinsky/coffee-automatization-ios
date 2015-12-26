//
//  DBPromosListViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 02.06.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBPromosListViewController.h"
#import "DBPromoCell.h"
#import "OrderCoordinator.h"

#import "MBProgressHUD.h"

@interface DBPromosListViewController ()

@end

@implementation DBPromosListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Список акций", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [GANHelper analyzeScreen:PROMOS_LIST_SCREEN];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[OrderCoordinator sharedInstance].promoManager.promotionList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBPromoCell *cell;
    
    DBPromotion *promotion = [OrderCoordinator sharedInstance].promoManager.promotionList[indexPath.row];
    DBPromoCellType type = DBPromoCellTypeGeneral;
    if (promotion.imageUrl.length > 0 && [NSURL URLWithString:promotion.imageUrl]) {
        if (promotion.imageType == DBPromotionImageTypeImage) {
            type = DBPromoCellTypeImage;
        } else {
            type = DBPromoCellTypePic;
        }
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:[DBPromoCell reuseIdentifier:type]];
    if(!cell){
        cell = [DBPromoCell create:type];
    }
    [cell configureWithPromo:promotion];
    
    return cell;
}

@end
