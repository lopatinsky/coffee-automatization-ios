//
//  DBMixedMenuModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 25/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBMixedMenuModuleView.h"

#import "DBMenu.h"
#import "DBMenuPosition.h"
#import "DBPositionCell.h"
#import "DBCategoryHeaderView.h"
#import "OrderCoordinator.h"
#import "Venue.h"
#import "DBMenuCategory.h"


@interface DBMixedMenuModuleView ()<DBPositionCellDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSArray *categoryHeaders;
@end

@implementation DBMixedMenuModuleView

+ (DBMixedMenuModuleView *)create {
    DBMixedMenuModuleView *view = [DBMixedMenuModuleView new];
    
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
    
    [self reloadTableView];
}

- (void)reloadContent {
    [self reloadTableView];
}

- (void)loadMenu:(UIRefreshControl *)refreshControl {
    [GANHelper analyzeEvent:@"menu_update" category:self.analyticsCategory];
    
    Venue *venue = [OrderCoordinator sharedInstance].orderManager.venue;

    [[DBMenu sharedInstance] updateMenu:^(BOOL success, NSArray *categories) {
        [refreshControl endRefreshing];
        if (success) {
            self.categories = [[DBMenu sharedInstance] getMenuForVenue:venue];
            [self reloadTableView];
        }
        
        if ([self.menuModuleDelegate respondsToSelector:@selector(db_menuModuleViewDidReloadContent:)]) {
            [self.menuModuleDelegate db_menuModuleViewDidReloadContent:self];
        }
    }];
}

- (void)scrollToCategory:(DBMenuCategory *)category {
    NSUInteger section = [self.categories indexOfObject:category];
    
    if(section != NSNotFound && section < [self.categories count]){
        [self scrollTableViewToSection:section];
    }
}

#pragma mark - UITableView methods

- (void)reloadTableView {
    NSMutableArray *headers = [NSMutableArray new];
    for (DBMenuCategory *category in self.categories) {
        DBCategoryHeaderView *headerView = [[DBCategoryHeaderView alloc] initWithMenuCategory:category];
        headerView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, headerView.frame.size.height);
        
        [headers addObject:headerView];
    }
    self.categoryHeaders = headers;
    
    [self.tableView reloadData];
}

- (void)scrollTableViewToSection:(NSInteger)section{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.categories count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DBMenuCategory *category = self.categories[section];
    return category.positions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBPositionCell *cell;
    DBMenuCategory *category = [self.categories objectAtIndex:indexPath.section];
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
    
    DBMenuPosition *position = ((DBMenuCategory *)self.categories[indexPath.section]).positions[indexPath.row];
    cell.contentType = DBPositionCellContentTypeRegular;
    cell.priceAnimated = YES;
    [cell configureWithPosition:position];
    cell.delegate = self;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    DBMenuCategory *category = [self.categories objectAtIndex:indexPath.section];
    if(category.categoryWithImages){
        return 120;
    } else {
        return 50;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    DBCategoryHeaderView *headerView = self.categoryHeaders[section];
    
    UIView *view = [[UIView alloc] initWithFrame:headerView.frame];
    view.backgroundColor = [UIColor clearColor];
    [view addSubview:headerView];
    
    return view;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DBPositionCell *cell = (DBPositionCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    DBMenuPosition *position = cell.position;
    
    if ([self.menuModuleDelegate respondsToSelector:@selector(db_menuModuleViewNeedsToMoveForward:object:)]) {
        [self.menuModuleDelegate db_menuModuleViewNeedsToMoveForward:self object:position];
    }
    
    [GANHelper analyzeEvent:@"product_selected" label:position.positionId category:self.analyticsCategory];
}

#pragma mark - DBPositionCellDelegate

- (void)positionCellDidOrder:(DBPositionCell *)cell {
    if ([self.menuModuleDelegate respondsToSelector:@selector(db_menuModuleViewNeedsToAddPosition:position:)]) {
        [self.menuModuleDelegate db_menuModuleViewNeedsToAddPosition:self position:cell.position];
    }
    [GANHelper analyzeEvent:@"product_price_click" label:cell.position.positionId category:self.analyticsCategory];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [GANHelper analyzeEvent:@"menu_scroll" category:self.analyticsCategory];
}

@end
