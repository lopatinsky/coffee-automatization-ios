//
//  DBPositionsMenuModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 25/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBPositionsMenuModuleView.h"

#import "DBPositionCell.h"
#import "DBPositionModifiersListModalView.h"

#import "OrderCoordinator.h"
#import "DBMenu.h"
#import "DBMenuCategory.h"
#import "DBMenuPosition.h"

@interface DBPositionsMenuModuleView ()<DBPositionCellDelegate, UITableViewDataSource, UITableViewDelegate>
@end

@implementation DBPositionsMenuModuleView

+ (DBPositionsMenuModuleView *)create {
    DBPositionsMenuModuleView *view = [DBPositionsMenuModuleView new];
    
    return view;
}

- (void)commonInit {
    [super commonInit];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)setCategory:(DBMenuCategory *)category {
    _category = category;
    
    if (DBMenu.type == DBMenuTypeSimple || category.positions.count > 0) {
        [self.tableView reloadData];
    } else {
        [MBProgressHUD showHUDAddedTo:self animated:YES];
        [[DBMenu sharedInstance] updateCategory:category callback:^(BOOL success) {
            [MBProgressHUD hideAllHUDsForView:self animated:YES];
            [self.tableView reloadData];
        }];
    }
}

- (void)reloadContent {
    [self.tableView reloadData];
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
    cell.priceAnimated = YES;
    
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
    
    DBPositionCell *cell = (DBPositionCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    DBMenuPosition *position = cell.position;
    
    if ([self.menuModuleDelegate respondsToSelector:@selector(db_menuModuleViewNeedsToMoveForward:object:)]) {
        [self.menuModuleDelegate db_menuModuleViewNeedsToMoveForward:self object:position];
    }
    
    [GANHelper analyzeEvent:@"product_selected" label:position.positionId category:MENU_SCREEN];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [GANHelper analyzeEvent:@"menu_scroll" category:CATEGORIES_SCREEN];
}

#pragma mark - DBPositionCellDelegate

- (void)positionCellDidOrder:(DBPositionCell *)cell{
    [GANHelper analyzeEvent:@"product_price_click" label:cell.position.positionId category:MENU_SCREEN];
    
    if ([self.menuModuleDelegate respondsToSelector:@selector(db_menuModuleViewNeedsToAddPosition:position:)]) {
        [self.menuModuleDelegate db_menuModuleViewNeedsToAddPosition:self position:cell.position];
    }
    [GANHelper analyzeEvent:@"product_price_click" label:cell.position.positionId category:self.analyticsCategory];
}

@end
