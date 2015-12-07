//
//  IHCategoryTableViewController.m
//  IIko Hackathon
//
//  Created by Balaban Alexander on 04/04/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "CategoriesTVController.h"
#import "PositionsTVController.h"
#import "CategoriesAndPositionsTVController.h"

#import "DBCategoryCell.h"
#import "OrderCoordinator.h"
#import "DBBarButtonItem.h"
#import "MBProgressHUD.h"
#import "Venue.h"
#import "DBMenu.h"
#import "DBMenuCategory.h"
#import "DBMenuPosition.h"
#import "DBSettingsTableViewController.h"
#import "DBSubscriptionManager.h"

#import "UINavigationController+DBAnimation.h"
#import "UIImageView+WebCache.h"

@interface CategoriesTVController (){
    MBProgressHUD *hud;
}

@property (nonatomic, strong) DBMenuCategory *parent;

@property (nonatomic, strong) NSArray *categories;
@property (strong, nonatomic) NSString *lastVenueId;

@end

@implementation CategoriesTVController
static NSDictionary *_preference;

#pragma mark - MenuListViewControllerProtocol
+ (instancetype)createViewController{
    return [CategoriesTVController new];
}

+ (instancetype)createWithMenuCategory:(DBMenuCategory *)category{
    CategoriesTVController *categoriesTVC = [self createViewController];
    categoriesTVC.parent = category;
    
    return categoriesTVC;
}

+ (NSDictionary *)preference {
    return _preference;
}

+ (void)setPreferences:(NSDictionary *)preferences {
    _preference = preferences;
}

#pragma mark - Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.topItem.title = @"";
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    // Order button
    self.navigationItem.rightBarButtonItem = [DBBarButtonItem orderItem:self action:@selector(moveToOrder)];
    
    if (self.parent) {
        [self db_setTitle:self.parent.name];
    } else {
        [self db_setTitle:NSLocalizedString(@"Меню", nil)];
        
        // Profile button
        self.navigationItem.leftBarButtonItem = [DBBarButtonItem profileItem:self action:@selector(moveToSettings)];
    }
    
    //styling
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [UIView new];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    if (!self.parent) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(loadMenu:) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refreshControl;
    
        hud = [[MBProgressHUD alloc] init];
        [self.navigationController.view addSubview:hud];
        
        [self loadMenu:nil];
    } else {
        _categories = self.parent.categories;
    }
    
    [self subscribeForNotifications];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [GANHelper analyzeScreen:CATEGORIES_SCREEN];
}

- (void)subscribeForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadMenu:) name:kDBSubscriptionManagerCategoryIsAvailable object:nil];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)appendSubscriptionCategory {
    if ([[DBSubscriptionManager sharedInstance] isEnabled]) {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:self.categories];
        [temp insertObject:[[DBSubscriptionManager sharedInstance] subscriptionCategory] atIndex:0];
        self.categories = [temp copy];
    }
}

- (void)loadMenu:(UIRefreshControl *)refreshControl{
    [GANHelper analyzeEvent:@"menu_update" category:MENU_SCREEN];
    void (^menuUpdateHandler)(BOOL, NSArray*) = ^void(BOOL success, NSArray *categories) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [refreshControl endRefreshing];
        
        if (success) {
            self.categories = categories;
            [self appendSubscriptionCategory];
            [self.tableView reloadData];
        }
        
        [self.tableView reloadData];
    };
    
    Venue *venue = [OrderCoordinator sharedInstance].orderManager.venue;
    if (refreshControl) {
        [[DBMenu sharedInstance] updateMenuForVenue:venue
                                         remoteMenu:menuUpdateHandler];
    } else {
        if (venue.venueId) {
            // Load menu for current Venue
            if(!self.lastVenueId || ![self.lastVenueId isEqualToString:venue.venueId]){
                self.lastVenueId = venue.venueId;
                
                self.categories = [[DBMenu sharedInstance] getMenuForVenue:venue];
                [self appendSubscriptionCategory];
            }
        } else {
            // Load whole menu
            self.categories = [[DBMenu sharedInstance] getMenu];
            [self appendSubscriptionCategory];
        }
        
        
        if (self.categories && [self.categories count] > 0){
            [self.tableView reloadData];
        } else {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[DBMenu sharedInstance] updateMenuForVenue:venue
                                             remoteMenu:menuUpdateHandler];
        }
    }
}

- (DBCategoryCellAppearanceType)cellType {
    if ([self hasImages]) {
        return DBCategoryCellAppearanceTypeFull;
    } else {
        return DBCategoryCellAppearanceTypeCompact;
    }
}

- (BOOL)hasImages {
    if (!self.parent) {
        return [DBMenu sharedInstance].hasImages;
    } else {
        return self.parent.categoryWithImages;
    }
}

- (void)moveToSettings {
    DBSettingsTableViewController *settingsController = [DBClassLoader loadSettingsViewController];
    [self.navigationController pushViewController:settingsController animated:YES];
}


#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self cellType] == DBCategoryCellAppearanceTypeFull) {
        return [ViewManager menuCategoriesFullCellHeight];
    } else {
        return [ViewManager menuCategoriesCompactCellHeight];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.categories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBCategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryTableViewCell"];
    if (!cell){
        cell = [[DBCategoryCell alloc] initWithType:[self cellType]];
    }
    
    DBMenuCategory *category = [self.categories objectAtIndex:indexPath.row];
    [cell configureWithCategory:category];
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DBMenuCategory *category = [self.categories objectAtIndex:indexPath.row];
    
    [GANHelper analyzeEvent:@"item_category_click" label:category.categoryId category:CATEGORIES_SCREEN];

    if (category.type == DBMenuCategoryTypeParent) {
        BOOL mixed = [[_preference objectForKey:@"is_mixed_type"] boolValue] && [category.categories count];
        DBMenuCategory *firstCategory = [category.categories firstObject];
        if (firstCategory && mixed && firstCategory.type == DBMenuCategoryTypeStandart) {
            CategoriesAndPositionsTVController *categoriesAndPositionsVC = [CategoriesAndPositionsTVController new];
            categoriesAndPositionsVC.categories = category.categories;
            [CategoriesAndPositionsTVController setPreferences:_preference];
            [self.navigationController pushViewController:categoriesAndPositionsVC animated:YES];
        } else {
            CategoriesTVController *categoriesVC = [CategoriesTVController new];
            categoriesVC.parent = category;
            categoriesVC.categories = category.categories;
            categoriesVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:categoriesVC animated:YES];
        }
    } else {
        PositionsTVController *tableVC = [PositionsTVController new];
        tableVC.category = category;
        tableVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:tableVC animated:YES];
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [GANHelper analyzeEvent:@"menu_scroll" category:CATEGORIES_SCREEN];
}


#pragma mark - other methods


- (void)moveToOrder {
    [self.navigationController pushViewController:[DBClassLoader loadNewOrderViewController] animated:YES];
    [GANHelper analyzeEvent:@"order_pressed" category:MENU_SCREEN];
}


@end
