//
//  DBCategoriesMenuModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 25/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBCategoriesMenuModuleView.h"

#import "DBCategoryCell.h"

#import "OrderCoordinator.h"
#import "DBMenu.h"
#import "DBMenuCategory.h"
#import "DBMenuPosition.h"
#import "Venue.h"

@interface DBCategoriesMenuModuleView ()<UITableViewDataSource, UITableViewDelegate>
@end

@implementation DBCategoriesMenuModuleView

+ (DBCategoriesMenuModuleView *)create {
    DBCategoriesMenuModuleView *view = [DBCategoriesMenuModuleView new];
    
    return view;
}

- (void)commonInit {
    [super commonInit];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)setUpdateEnabled:(BOOL)updateEnabled {
    if (updateEnabled) {
        UIRefreshControl *refreshControl = [UIRefreshControl new];
        [refreshControl addTarget:self action:@selector(loadMenu:) forControlEvents:UIControlEventValueChanged];
        [self.tableView addSubview:refreshControl];
    }
}

- (void)setCategories:(NSArray *)categories {
    _categories = categories;
    
    [self.tableView reloadData];
}

- (void)reloadContent {
    [self.tableView reloadData];
}

- (void)loadMenu:(UIRefreshControl *)refreshControl {
    [GANHelper analyzeEvent:@"menu_update" category:self.analyticsCategory];
    
    Venue *venue = [OrderCoordinator sharedInstance].orderManager.venue;
    
    [[DBMenu sharedInstance] updateMenu:^(BOOL success, NSArray *categories) {
        [refreshControl endRefreshing];
        if (success) {
            self.categories = [[DBMenu sharedInstance] getMenuForVenue:venue];
            [self.tableView reloadData];
        }
        
        if ([self.menuModuleDelegate respondsToSelector:@selector(db_menuModuleViewDidReloadContent:)]) {
            [self.menuModuleDelegate db_menuModuleViewDidReloadContent:self];
        }
    }];
}

- (BOOL)hasImages {
    if(!self.parent){
        return [DBMenu sharedInstance].hasImages;
    } else {
        return self.parent.categoryWithImages;
    }
}

- (DBCategoryCellAppearanceType)cellType {
    if ([self hasImages]) {
        return DBCategoryCellAppearanceTypeFull;
    } else {
        return DBCategoryCellAppearanceTypeCompact;
    }
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self cellType] == DBCategoryCellAppearanceTypeFull) {
        return [[DBClassLoader loadCategoryCell] height:DBCategoryCellAppearanceTypeFull];
    } else {
        return [[DBClassLoader loadCategoryCell] height:DBCategoryCellAppearanceTypeCompact];
    }

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.categories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBCategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryTableViewCell"];
    if (!cell || cell.appearanceType != [self cellType]){
        Class<DBCategoryCellProtocol> cellClass = [DBClassLoader loadCategoryCell];
        cell = [cellClass create:[self cellType]];
    }
    
    DBMenuCategory *category = [self.categories objectAtIndex:indexPath.row];
    [cell configureWithCategory:category];
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DBMenuCategory *category = [self.categories objectAtIndex:indexPath.row];
    
    [GANHelper analyzeEvent:@"item_category_click" label:category.categoryId category:self.analyticsCategory];
    
    if ([self.menuModuleDelegate respondsToSelector:@selector(db_menuModuleViewNeedsToMoveForward:object:)]) {
        [self.menuModuleDelegate db_menuModuleViewNeedsToMoveForward:self object:category];
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [GANHelper analyzeEvent:@"menu_scroll" category:self.analyticsCategory];
}

@end
