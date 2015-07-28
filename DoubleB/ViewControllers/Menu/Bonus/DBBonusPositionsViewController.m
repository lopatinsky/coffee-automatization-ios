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
#import "DBMenuPositionModifier.h"
#import "OrderCoordinator.h"
#import "DBMenuBonusPosition.h"
#import "ViewControllerManager.h"

@interface DBBonusPositionsViewController ()<UITableViewDelegate, UITableViewDataSource, DBPositionCellDelegate>
@property (weak, nonatomic) IBOutlet UIView *promoDescriptionView;
@property (weak, nonatomic) IBOutlet UILabel *promoDescriptionTitle;
@property (weak, nonatomic) IBOutlet UILabel *promoBalanceLabel;
@property (weak, nonatomic) IBOutlet UIView *promoDescriptionSeparatorView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) DBPromoManager *promoManager;

@property (nonatomic) BOOL withImages;
@end

@implementation DBBonusPositionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Бонусы", nil);
    self.navigationItem.leftBarButtonItem.title = @"";
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.promoManager = [OrderCoordinator sharedInstance].promoManager;
    
    self.promoDescriptionTitle.text = _promoManager.bonusPositionsTextDescription;
    [self reloadBalance];
    self.promoDescriptionSeparatorView.backgroundColor = [UIColor db_separatorColor];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [UIView new];
    
    self.withImages = NO;
    for (DBMenuPosition *position in _promoManager.positionsAvailableAsBonuses) {
        self.withImages = self.withImages || position.hasImage;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self reloadBalance];
    [self.tableView reloadData];
}

- (double)totalPoints{
    return _promoManager.bonusPointsBalance - [OrderCoordinator sharedInstance].bonusItemsManager.totalPrice;
}

- (void)reloadBalance{
    double totalPoints = [self totalPoints];
    
    self.promoBalanceLabel.text = [NSString stringWithFormat:@"%@: %.0f", NSLocalizedString(@"Баланс", nil), totalPoints];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_promoManager.positionsAvailableAsBonuses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBPositionCell *cell;
    
    if (self.withImages){
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
    
    DBMenuPosition *position = _promoManager.positionsAvailableAsBonuses[indexPath.row];
    [cell configureWithPosition:position];
    
    if ([position.productDictionary[@"points"] floatValue] <= [self totalPoints]) {
        [cell enable];
    } else {
        [cell disable];
    }
    
    cell.delegate = self;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.withImages) {
        return 120;
    } else {
        return 44;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DBMenuPosition *position =_promoManager.positionsAvailableAsBonuses[indexPath.row];
    UIViewController<PositionViewControllerProtocol> *positionVC = [[ViewControllerManager positionViewController] initWithPosition:position mode:PositionViewControllerModeMenuPosition];
    positionVC.parentNavigationController = self.navigationController;
    positionVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:positionVC animated:YES];
}

#pragma mark - DBPositionCellDelegate

- (void)positionCellDidOrder:(DBPositionCell *)cell{
    DBMenuPosition *position = cell.position;
    
    if([position.productDictionary[@"points"] floatValue] <= [self totalPoints]) {
        [[OrderCoordinator sharedInstance].bonusItemsManager addBonusPosition:(DBMenuBonusPosition *)cell.position];
        
        [self reloadBalance];
        [self.tableView reloadData];
    }
}

@end
