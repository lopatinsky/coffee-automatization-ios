//
//  DBGiftsViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 20.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBBonusPositionsViewController.h"
#import "DBPositionCell.h"
#import "DBMenuPosition.h"
#import "DBPromoManager.h"
#import "OrderManager.h"
#import "DBMenuBonusPosition.h"

@interface DBBonusPositionsViewController ()<UITableViewDelegate, UITableViewDataSource, DBPositionCellDelegate>
@property (weak, nonatomic) IBOutlet UIView *promoDescriptionView;
@property (weak, nonatomic) IBOutlet UILabel *promoDescriptionTitle;
@property (weak, nonatomic) IBOutlet UILabel *promoBalanceTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *promoBalanceLabel;
@property (weak, nonatomic) IBOutlet UIView *promoDescriptionSeparatorView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) BOOL withImages;
@end

@implementation DBBonusPositionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Бонусы", nil);
    self.navigationItem.leftBarButtonItem.title = @"";
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.promoDescriptionTitle.text = [DBPromoManager sharedManager].bonusPositionsTextDescription;
    self.promoBalanceTitleLabel.text = NSLocalizedString(@"Баланс:", nil);
    [self reloadBalance];
    self.promoDescriptionSeparatorView.backgroundColor = [UIColor db_separatorColor];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [UIView new];
    
    self.withImages = NO;
    for(DBMenuPosition *position in [DBPromoManager sharedManager].positionsAvailableAsBonuses){
        self.withImages = self.withImages || position.hasImage;
    }
}

- (double)totalPoints{
    return [DBPromoManager sharedManager].bonusPointsBalance - [OrderManager sharedManager].totalBonusPositionsPrice;
}

- (void)reloadBalance{
    double totalPoints = [self totalPoints];
    
    self.promoBalanceLabel.text = [NSString stringWithFormat:@"%.0f", totalPoints];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[DBPromoManager sharedManager].positionsAvailableAsBonuses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBPositionCell *cell;
    
    if(self.withImages){
        cell = [tableView dequeueReusableCellWithIdentifier:@"DBPositionCell"];
        if (!cell) {
            cell = [[DBPositionCell alloc] initWithType:DBPositionCellAppearanceTypeFull];
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"DBPositionCompactCell"];
        if (!cell) {
            cell = [[DBPositionCell alloc] initWithType:DBPositionCellAppearanceTypeCompact];
        }
    }
    
    DBMenuBonusPosition *position = [DBPromoManager sharedManager].positionsAvailableAsBonuses[indexPath.row];
    [cell configureWithPosition:position];
    
    if(position.pointsPrice <= [self totalPoints]){
        [cell enable];
    } else {
        [cell disable];
    }
    
    cell.delegate = self;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.withImages){
        return 120;
    } else {
        return 44;
    }
}

#pragma mark - DBPositionCellDelegate

- (void)positionCellDidOrder:(DBPositionCell *)cell{
    DBMenuBonusPosition *position = (DBMenuBonusPosition *)cell.position;
    
    if(position.pointsPrice <= [self totalPoints]){
        [[OrderManager sharedManager] addBonusPosition:(DBMenuBonusPosition *)cell.position];
        
        [self reloadBalance];
        [self.tableView reloadData];
    }
}

@end
