//
//  DBGiftsViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 20.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBBonusPositionsViewController.h"
#import "DBPositionCell.h"
#import "DBBonusPositionDescriptionCell.h"
#import "DBMenuPosition.h"
#import "DBPromoManager.h"
#import "OrderManager.h"

@interface DBBonusPositionsViewController ()<UITableViewDelegate, UITableViewDataSource, DBPositionCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) BOOL withImages;
@end

@implementation DBBonusPositionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Бонусы", nil);
    self.navigationItem.leftBarButtonItem.title = @"";
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [UIView new];
    
    self.withImages = NO;
    for(DBMenuPosition *position in [DBPromoManager sharedManager].positionsAvailableAsBonuses){
        self.withImages = self.withImages || position.hasImage;
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return 1;
    } else {
        return [[DBPromoManager sharedManager].positionsAvailableAsBonuses count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        DBBonusPositionDescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBBonusPositionDescriptionCell"];
        if(!cell){
            cell = [DBBonusPositionDescriptionCell new];
        }
        
        cell.balance = [DBPromoManager sharedManager].bonusPointsBalance;
        
        return cell;
    } else {
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
        
        DBMenuPosition *position = [DBPromoManager sharedManager].positionsAvailableAsBonuses[indexPath.row];
        [cell configureWithPosition:position];
        cell.delegate = self;
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        return 80.f;
    } else {
        if(self.withImages){
            return 120;
        } else {
            return 44;
        }
    }
}

#pragma mark - DBPositionCellDelegate

- (void)positionCellDidOrder:(DBPositionCell *)cell{
    [[OrderManager sharedManager] addBonusPosition:(DBMenuBonusPosition *)cell.position];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
