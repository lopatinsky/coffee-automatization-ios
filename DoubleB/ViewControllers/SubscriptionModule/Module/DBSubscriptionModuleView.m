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

#import "UIAlertView+BlocksKit.h"

@interface DBSubscriptionModuleView ()<UITableViewDataSource, UITableViewDelegate, DBPositionCellDelegate>
@property (strong, nonatomic) DBCategoryCell *cell;
@property (strong, nonatomic) UITableView *tableView;

@end

@implementation DBSubscriptionModuleView

+ (DBSubscriptionModuleView*)create:(DBSubscriptionModuleViewMode)mode{
    DBSubscriptionModuleView *view = [DBSubscriptionModuleView new];
    view.mode = mode;
    
    return view;
}

- (void)commonInit {
    self.clipsToBounds = YES;
    
    if (_mode == DBSubscriptionModuleViewModeCategory) {
        DBCategoryCellAppearanceType type = [DBSubscriptionManager sharedInstance].subscriptionCategory.hasImage ? DBCategoryCellAppearanceTypeFull : DBCategoryCellAppearanceTypeCompact;
        DBCategoryCell *cell = [[DBCategoryCell alloc] initWithType:type];
        [cell configureWithCategory:[DBSubscriptionManager sharedInstance].subscriptionCategory];
        [self addSubview:cell];
        cell.translatesAutoresizingMaskIntoConstraints = NO;
        [cell alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self];
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
}

- (void)pushSubscriptionViewController {
    UIViewController<SubscriptionViewControllerProtocol> *subscriptionVC = [ViewControllerManager subscriptionViewController];
    [self.ownerViewController.navigationController pushViewController:subscriptionVC animated:YES];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [DBSubscriptionManager sharedInstance].subscriptionCategory.positions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        SubscriptionInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SubscriptionCell"];
        if ([[DBSubscriptionManager sharedInstance] isAvailable]) {
            cell.placeholderView.hidden = YES;
            cell.numberOfCupsLabel.text = [NSString stringWithFormat:@"x %ld", (long)[[DBSubscriptionManager sharedInstance] numberOfAvailableCups]];
            cell.numberOfDaysLabel.text = [NSString stringWithFormat:@"%@", [[[DBSubscriptionManager sharedInstance] currentSubscription] days]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.userInteractionEnabled = NO;
        } else {
            cell.placeholderView.hidden = NO;
            cell.subscriptionAds.text = [DBSubscriptionManager sharedInstance].subscriptionMenuTitle;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }
    
    DBPositionCell *cell;
    DBMenuCategory *category = [DBSubscriptionManager sharedInstance].subscriptionCategory;
    if (category.categoryWithImages){
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
    
    DBMenuPosition *position = category.positions[indexPath.row];
    cell.contentType = DBPositionCellContentTypeRegular;
    cell.priceAnimated = YES;
    [cell configureWithPosition:position];
    cell.delegate = self;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([DBSubscriptionManager sharedInstance].subscriptionCategory.categoryWithImages){
        return 120;
    } else {
        return 50;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.mode == DBSubscriptionModuleViewModeCategoriesAndPositions) {
        return 40.f;
    } else {
        return 0;
    }
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
        }
    }
}

@end
