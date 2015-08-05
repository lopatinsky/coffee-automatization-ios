//
//  IHCategoryTableViewController.m
//  IIko Hackathon
//
//  Created by Balaban Alexander on 04/04/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "CategoriesTVController.h"
#import "DBCategoryCell.h"
#import "PositionsTVController.h"
#import "DBNewOrderViewController.h"
#import "OrderCoordinator.h"
#import "DBBarButtonItem.h"
#import "MBProgressHUD.h"
#import "Venue.h"
#import "DBMenu.h"
#import "DBMenuCategory.h"
#import "DBMenuPosition.h"

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

+ (instancetype)createViewController{
    return [CategoriesTVController new];
}

+ (instancetype)createWithMenuCategory:(DBMenuCategory *)category{
    CategoriesTVController *categoriesTVC = [self createViewController];
    categoriesTVC.parent = category;
    
    return categoriesTVC;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.topItem.title = @"";
    
    if (self.parent) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationItem.title = self.parent.name;
    } else {
        self.navigationItem.leftBarButtonItem = [[DBBarButtonItem alloc] initWithViewController:self action:@selector(goToOrderViewController)];
        self.navigationItem.title = NSLocalizedString(@"Меню", nil);
    }
    
    //styling
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [UIView new];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    if(!self.parent){
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(loadMenu:) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refreshControl;
    
        hud = [[MBProgressHUD alloc] init];
        [self.navigationController.view addSubview:hud];
        
        [self loadMenu:nil];
    } else {
        _categories = self.parent.categories;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [GANHelper analyzeScreen:CATEGORIES_SCREEN];
}

- (void)dealloc{
}

- (void)loadMenu:(UIRefreshControl *)refreshControl{
    [GANHelper analyzeEvent:@"menu_update" category:MENU_SCREEN];
    void (^menuUpdateHandler)(BOOL, NSArray*) = ^void(BOOL success, NSArray *categories) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [refreshControl endRefreshing];
        
        if (success) {
            self.categories = categories;
            [self.tableView reloadData];
        }
        
        [self.tableView reloadData];
    };
    
    Venue *venue = [OrderCoordinator sharedInstance].orderManager.venue;
    if(refreshControl){
        [[DBMenu sharedInstance] updateMenuForVenue:venue
                                         remoteMenu:menuUpdateHandler];
    } else {
        if(venue.venueId){
            // Load menu for current Venue
            if(!self.lastVenueId || ![self.lastVenueId isEqualToString:venue.venueId]){
                self.lastVenueId = venue.venueId;
                
                self.categories = [[DBMenu sharedInstance] getMenuForVenue:venue];
            }
        } else {
            // Load whole menu
            self.categories = [[DBMenu sharedInstance] getMenu];
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


#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.categories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBCategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryTableViewCell"];
    if (!cell){
        cell = [DBCategoryCell new];
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
        CategoriesTVController *categoriesVC = [CategoriesTVController new];
        categoriesVC.parent = category;
        categoriesVC.categories = category.categories;
        categoriesVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:categoriesVC animated:YES];
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


- (void)goToOrderViewController
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [GANHelper analyzeEvent:@"order_pressed" category:MENU_SCREEN];
}


@end
