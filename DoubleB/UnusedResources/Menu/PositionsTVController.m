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
static NSDictionary *_preference;

#pragma mark - MenuListViewControllerProtocol
+ (instancetype)createWithMenuCategory:(DBMenuCategory *)category{
    PositionsTVController *positionsTVC = [PositionsTVController new];
    positionsTVC.category = category;
    
    return positionsTVC;
}

+ (NSDictionary *)preference {
    return _preference;
}

+ (void)setPreferences:(NSDictionary *)preferences {
    _preference = preferences;
}

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self db_setTitle:self.category.name];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.navigationItem.rightBarButtonItem = [DBBarButtonItem orderItem:self action:@selector(moveToOrder)];

    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SubscriptionInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"SubscriptionCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [DBSubscriptionManager sharedInstance].delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [DBSubscriptionManager sharedInstance].delegate = nil;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [GANHelper analyzeScreen:POSITIONS_SCREEN];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.category.positions count] + [DBSubscriptionManager numberOfRowsInSection:section forCategory:self.category];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SubscriptionInfoTableViewCell *cell = [DBSubscriptionManager tryToDequeueSubscriptionCellForCategory:self.category
                                                                                           withIndexPath:indexPath
                                                                                                 andCell:[tableView dequeueReusableCellWithIdentifier:@"SubscriptionCell"]];
    NSIndexPath *correctedIndexPath = [DBSubscriptionManager correctedIndexPath:indexPath forCategory:self.category];
    
    if (cell) {
//        cell.delegate = self;
        return cell;
    } else {
        DBPositionCell *cell;
        if (self.category.categoryWithImages) {
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
        
        DBMenuPosition *position = self.category.positions[correctedIndexPath.row];
        [cell configureWithPosition:position];
        
        return cell;
    }
}


#pragma mark - table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.category.categoryWithImages) {
        return 120;
    } else {
        return 50;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([[DBSubscriptionManager sharedInstance] isEnabled] && [DBSubscriptionManager categoryIsSubscription:self.category]) {
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
    if ([DBSubscriptionManager isSubscriptionPosition:idxPath] && [DBSubscriptionManager categoryIsSubscription:self.category]) {
        if (![self subscriptionPositionDidOrder:cell]) {
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
