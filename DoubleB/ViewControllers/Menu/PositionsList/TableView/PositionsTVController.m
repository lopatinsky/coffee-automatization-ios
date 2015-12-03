//
//  IHProductTableViewController.m
//  IIko Hackathon
//
//  Created by Balaban Alexander on 04/04/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PositionsTVController.h"
#import "DBPositionCell.h"
#import "OrderCoordinator.h"
#import "DBBarButtonItem.h"
#import "DBMenu.h"
#import "DBMenuCategory.h"
#import "DBMenuPosition.h"
#import "DBPositionModifiersListModalView.h"
#import "DBSubscriptionManager.h"
#import "SubscriptionInfoTableViewCell.h"

#import "PositionViewControllerProtocol.h"

#import "UIImageView+WebCache.h"
#import "UIAlertView+BlocksKit.h"

#import "UINavigationController+DBAnimation.h"

@interface PositionsTVController () <DBPositionCellDelegate, DBSubscriptionManagerProtocol, SubscriptionViewControllerDelegate>
@end

@implementation PositionsTVController

+ (instancetype)createWithMenuCategory:(DBMenuCategory *)category{
    PositionsTVController *positionsTVC = [PositionsTVController new];
    positionsTVC.category = category;
    
    return positionsTVC;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self db_setTitle:self.category.name];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.navigationItem.rightBarButtonItem = [DBBarButtonItem orderItem:self action:@selector(moveToOrder)];

    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SubscriptionInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"SubscriptionCell"];
    
    [DBSubscriptionManager sharedInstance].delegate = self;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [GANHelper analyzeScreen:POSITIONS_SCREEN];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[DBSubscriptionManager sharedInstance] isEnabled] && [self.category.categoryId isEqualToString:@"1"]) {
        return [self.category.positions count] + 1;
    } else {
        return [self.category.positions count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[DBSubscriptionManager sharedInstance] isEnabled] && [[DBSubscriptionManager sharedInstance] subscriptionCategory] && [self.category.categoryId isEqualToString:@"1"]) {
        if (indexPath.section == 0) {
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
                    cell.delegate = self;
                    cell.subscriptionAds.text = [DBSubscriptionManager sharedInstance].subscriptionMenuTitle;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                return cell;
            }
            indexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
        }
    }

    DBPositionCell *cell;
    if(self.category.categoryWithImages){
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
    
    DBMenuPosition *position = self.category.positions[indexPath.row];
    [cell configureWithPosition:position];

    return cell;
}


#pragma mark - table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.category.categoryWithImages){
        return 120;
    } else {
        return 50;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([[DBSubscriptionManager sharedInstance] isEnabled] && [self.category.categoryId isEqualToString:@"1"]) {
        if (indexPath.section == 0 && indexPath.row != 0 && ![[DBSubscriptionManager sharedInstance] isAvailable]) {
            [GANHelper analyzeEvent:@"abonement_product_select" category:MENU_SCREEN];
            [self pushSubscriptionViewController];
        } else if (indexPath.section == 0 && indexPath.row == 0) {
            return;
        }
    } else {
        DBPositionCell *cell = (DBPositionCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        DBMenuPosition *position = cell.position;
        
        UIViewController<PositionViewControllerProtocol> *positionVC = [[ViewControllerManager positionViewController] initWithPosition:position mode:PositionViewControllerModeMenuPosition];
        positionVC.parentNavigationController = self.navigationController;
        [self.navigationController pushViewController:positionVC animated:YES];
        
        [GANHelper analyzeEvent:@"product_selected" label:position.positionId category:MENU_SCREEN];
    }
}

- (void)pushSubscriptionViewController {
    UIViewController<SubscriptionViewControllerProtocol> *subscriptionVC = [ViewControllerManager subscriptionViewController];
    subscriptionVC.delegate = self;
    [self.navigationController pushViewController:subscriptionVC animated:YES];
}

- (void)moveToOrder {
    [self.navigationController pushViewController:[DBClassLoader loadNewOrderViewController] animated:YES];
    [GANHelper analyzeEvent:@"order_pressed" category:MENU_SCREEN];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [GANHelper analyzeEvent:@"menu_scroll" category:CATEGORIES_SCREEN];
}

#pragma mark - DBPositionCellDelegate

#pragma mark - DBPositionCellDelegate

- (BOOL)subscriptionPositionDidOrder:(DBPositionCell *)cell {
    if (![[DBSubscriptionManager sharedInstance] isAvailable]) {
        [self pushSubscriptionViewController];
        return NO;
    } else {
        if (![[DBSubscriptionManager sharedInstance] cupIsAvailableToPurchase]) {
            [GANHelper analyzeEvent:@"abonement_offer" category:MENU_SCREEN];
            [UIAlertView bk_showAlertViewWithTitle:@"Закончились кружки" message:@"Приобрести ещё?" cancelButtonTitle:@"Отмена" otherButtonTitles:@[@"Да"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    [GANHelper analyzeEvent:@"abonement_offer_yes" category:MENU_SCREEN];
                    [self pushSubscriptionViewController];
                } else {
                    [GANHelper analyzeEvent:@"abonement_offer_no" category:MENU_SCREEN];
                }
            }];
            return NO;
        } else {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            return YES;
        }
    }
}

- (void)positionCellDidOrder:(DBPositionCell *)cell {
    NSIndexPath *idxPath = [self.tableView indexPathForCell:cell];
    if ([[DBSubscriptionManager sharedInstance] isEnabled] && idxPath.section == 0) {
        if(![self subscriptionPositionDidOrder:cell]) {
            return;
        }
    }
    
    if (cell.position.hasEmptyRequiredModifiers) {
        DBPositionModifiersListModalView *modifiersList = [DBPositionModifiersListModalView new];
        [modifiersList configureWithMenuPosition:cell.position];
        [modifiersList showOnView:self.navigationController.view appearance:DBPopupAppearanceModal transition:DBPopupTransitionBottom];
    } else {
        [[OrderCoordinator sharedInstance].itemsManager addPosition:cell.position];
    }
    
    [GANHelper analyzeEvent:@"product_added" label:cell.position.positionId category:MENU_SCREEN];
    [GANHelper analyzeEvent:@"product_price_click" label:cell.position.positionId category:MENU_SCREEN];
}

#pragma mark - DBSubscriberManagerDelegate

- (void)currentSubscriptionStateChanged {
    if ([[DBSubscriptionManager sharedInstance] isEnabled]) {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark – SubscriptionViewControllerProtocol

- (void)subscriptionViewControllerWillDissappear {
    [self.tableView reloadData];
}

@end
