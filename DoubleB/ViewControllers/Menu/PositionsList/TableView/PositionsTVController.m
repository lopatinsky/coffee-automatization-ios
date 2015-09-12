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
#import "DBNewOrderViewController.h"
#import "OrderCoordinator.h"
#import "DBBarButtonItem.h"
#import "DBMenu.h"
#import "DBMenuCategory.h"
#import "DBMenuPosition.h"
#import "DBPositionModifiersListModalView.h"

#import "PositionViewControllerProtocol.h"

#import "UIImageView+WebCache.h"

#import "UINavigationController+DBAnimation.h"

@interface PositionsTVController () <DBPositionCellDelegate>
@end

@implementation PositionsTVController

+ (instancetype)createWithMenuCategory:(DBMenuCategory *)category{
    PositionsTVController *positionsTVC = [PositionsTVController new];
    positionsTVC.category = category;
    
    return positionsTVC;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[DBBarButtonItem alloc] initWithViewController:self action:@selector(goToOrderViewController)];
    
    [self db_setTitle:self.category.name];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [GANHelper analyzeScreen:POSITIONS_SCREEN];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.category.positions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
        return 44;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DBPositionCell *cell = (DBPositionCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    DBMenuPosition *position = cell.position;
    
    UIViewController<PositionViewControllerProtocol> *positionVC = [[ViewControllerManager positionViewController] initWithPosition:position mode:PositionViewControllerModeMenuPosition];
    positionVC.parentNavigationController = self.navigationController;
    [self.navigationController pushViewController:positionVC animated:YES];
    
    [GANHelper analyzeEvent:@"product_selected" label:position.positionId category:MENU_SCREEN];
}

- (void)goToOrderViewController {
    [self.navigationController popToRootViewControllerAnimated:YES];
    [GANHelper analyzeEvent:@"order_pressed" category:MENU_SCREEN];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [GANHelper analyzeEvent:@"menu_scroll" category:CATEGORIES_SCREEN];
}

#pragma mark - DBPositionCellDelegate

- (void)positionCellDidOrder:(DBPositionCell *)cell{
    [GANHelper analyzeEvent:@"product_price_click" label:cell.position.positionId category:MENU_SCREEN];
    
    if(cell.position.hasEmptyRequiredModifiers) {
        DBPositionModifiersListModalView *modifiersList = [DBPositionModifiersListModalView new];
        [modifiersList configureWithMenuPosition:cell.position];
        [modifiersList showOnView:self.navigationController.view withAppearance:DBPopupViewComponentAppearanceModal];
    } else {
        [self.navigationController animateAddProductFromView:cell.priceLabel completion:^{
            [[OrderCoordinator sharedInstance].itemsManager addPosition:cell.position];
        }];
    }
    
//    DBPositionModifiersListView *modifiersList = [DBPositionModifiersListView new];
//    [modifiersList configureWithMenuPosition:cell.position];
//    [modifiersList showOnView:self.navigationController.view withTransition:DBPopupViewComponentAppearanceBottom];
}

@end
