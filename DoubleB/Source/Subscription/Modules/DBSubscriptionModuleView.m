//
//  DBSubscriptionModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 14/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBSubscriptionModuleView.h"
#import "DBSubscriptionManager.h"

#import "DBPositionCell.h"
#import "SubscriptionInfoTableViewCell.h"
#import "DBCategoryHeaderView.h"

#import "DBMenuCategory.h"
#import "DBMenuPosition.h"

#import "DBPositionModifiersListModalView.h"
#import "DBMenuViewController.h"
#import "DBSubscriptionPositionsViewController.h"

#import "OrderCoordinator.h"

#import "UIAlertView+BlocksKit.h"

@interface DBSubscriptionModuleView ()<UITableViewDataSource, UITableViewDelegate, DBPositionCellDelegate, DBSubscriptionManagerProtocol>
@property (strong, nonatomic) DBCategoryCell *cell;
@property (strong, nonatomic) UITableView *tableView;

@end

@implementation DBSubscriptionModuleView

+ (DBSubscriptionModuleView*)create:(DBSubscriptionModuleViewMode)mode{
    DBSubscriptionModuleView *view = [DBSubscriptionModuleView create];
    view.mode = mode;
    [view config];
    
    return view;
}

- (void)viewWillAppearOnVC {
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)config {
    self.clipsToBounds = YES;
    
    if (_mode == DBSubscriptionModuleViewModeCategory) {
        DBCategoryCellAppearanceType type = [DBSubscriptionManager sharedInstance].subscriptionCategory.hasImage ? DBCategoryCellAppearanceTypeFull : DBCategoryCellAppearanceTypeCompact;
        
        Class<DBCategoryCellProtocol> cellClass = [DBClassLoader loadCategoryCell];
        self.cell = [cellClass create:type];
        
        [self.cell configureWithCategory:[DBSubscriptionManager sharedInstance].subscriptionCategory];
        [self addSubview:self.cell];
        self.cell.translatesAutoresizingMaskIntoConstraints = NO;
        [self.cell alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self];
    } else {
        self.tableView = [UITableView new];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.tableFooterView = [UIView new];
        [self addSubview:self.tableView];
        self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.tableView alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self];
        
        [self.tableView reloadData];
    }
    
    [DBSubscriptionManager sharedInstance].delegate = self;
}

- (void)pushSubscriptionViewController {
    UIViewController<SubscriptionViewControllerProtocol> *subscriptionVC = [ViewControllerManager subscriptionViewController];
    [self.ownerViewController.navigationController pushViewController:subscriptionVC animated:YES];
}

- (CGFloat)moduleViewContentHeight {
    if (_mode == DBSubscriptionModuleViewModeCategory) {
        return self.cell.frame.size.height;
    } else {
        return ([DBSubscriptionManager sharedInstance].subscriptionCategory.positions.count + 1) * [self heightForRow:0] + [self heightForHeader:0];
    }
}

- (void)touchAtLocation:(CGPoint)location {
    if (_mode == DBSubscriptionModuleViewModeCategory) {
        DBSubscriptionPositionsViewController *positionsVC = [DBSubscriptionPositionsViewController new];
        [self.ownerViewController.navigationController pushViewController:positionsVC animated:YES];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [DBSubscriptionManager sharedInstance].subscriptionCategory.positions.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SubscriptionInfoTableViewCell *cell = [DBSubscriptionManager tryToDequeueSubscriptionCellWithIndexPath:indexPath];
    NSIndexPath *correctedIndexPath = [DBSubscriptionManager correctedIndexPath:indexPath];
    
    if (cell) {
        cell.delegate = self;
        return cell;
    } else {
        DBPositionCell *cell;
        if ([[[DBSubscriptionManager sharedInstance] subscriptionCategory] categoryWithImages]) {
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
        cell.delegate = self;
        cell.priceAnimated = YES;
        
        DBMenuPosition *position = [[DBSubscriptionManager sharedInstance] subscriptionCategory].positions[correctedIndexPath.row];
        [cell configureWithPosition:position];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self heightForRow:indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return [self heightForHeader:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.mode == DBSubscriptionModuleViewModeCategoriesAndPositions) {
        DBCategoryHeaderView *headerView = [[DBCategoryHeaderView alloc] initWithMenuCategory:[DBSubscriptionManager sharedInstance].subscriptionCategory];
        headerView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, headerView.frame.size.height);
        
        return headerView;
    } else {
        return nil;
    }
}

- (CGFloat)heightForRow:(NSInteger)row {
    if([DBSubscriptionManager sharedInstance].subscriptionCategory.categoryWithImages){
        return 120;
    } else {
        return 50;
    }
}

- (CGFloat)heightForHeader:(NSInteger)section {
    if (self.mode == DBSubscriptionModuleViewModeCategoriesAndPositions) {
        return 40.f;
    } else {
        return 0;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([[DBSubscriptionManager sharedInstance] isEnabled]) {
        if (indexPath.row != 0 && ![[DBSubscriptionManager sharedInstance] isAvailable]) {
            [GANHelper analyzeEvent:@"abonement_product_select" category:MENU_SCREEN];
            [self pushSubscriptionViewController];
        }
    } else {
        DBPositionCell *cell = (DBPositionCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        DBMenuPosition *position = cell.position;
        
        UIViewController<PositionViewControllerProtocol> *positionVC = [[ViewControllerManager positionViewController] initWithPosition:position mode:PositionViewControllerModeMenuPosition];
        [self.ownerViewController.navigationController pushViewController:positionVC animated:YES];
        
        [GANHelper analyzeEvent:@"product_selected" label:position.positionId category:MENU_SCREEN];
    }
}

#pragma mark - DBPositionCellDelegate

- (void)positionCellDidOrder:(DBPositionCell *)cell {
    if (![[DBSubscriptionManager sharedInstance] isAvailable]) {
        [self pushSubscriptionViewController];
    } else {
        if (![[DBSubscriptionManager sharedInstance] cupIsAvailableToPurchase]) {
            [GANHelper analyzeEvent:@"abonement_offer" category:MENU_SCREEN];
            
            [UIAlertView bk_showAlertViewWithTitle:@"Закончились кружки"
                                           message:@"Приобрести ещё?"
                                 cancelButtonTitle:@"Отмена"
                                 otherButtonTitles:@[@"Да"]
                                           handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                               if (buttonIndex == 1) {
                                                   [GANHelper analyzeEvent:@"abonement_offer_yes" category:MENU_SCREEN];
                                                   [self pushSubscriptionViewController];
                                               } else {
                                                   [GANHelper analyzeEvent:@"abonement_offer_no" category:MENU_SCREEN];
                                               }
                                           }];
        } else {
            if (cell.position.hasEmptyRequiredModifiers) {
                DBPositionModifiersListModalView *modifiersList = [DBPositionModifiersListModalView new];
                [modifiersList configureWithMenuPosition:cell.position];
                [modifiersList showOnView:self.ownerViewController.navigationController.view appearance:DBPopupAppearanceModal transition:DBPopupTransitionBottom];
            } else {
                [[OrderCoordinator sharedInstance].itemsManager addPosition:cell.position];
            }
            [GANHelper analyzeEvent:@"product_added" label:cell.position.positionId category:MENU_SCREEN];
            [GANHelper analyzeEvent:@"product_price_click" label:cell.position.positionId category:MENU_SCREEN];
        }
    }
}

#pragma mark - DBSubscriberManagerDelegate

- (void)currentSubscriptionStateChanged {
    if ([[DBSubscriptionManager sharedInstance] isEnabled]) {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
