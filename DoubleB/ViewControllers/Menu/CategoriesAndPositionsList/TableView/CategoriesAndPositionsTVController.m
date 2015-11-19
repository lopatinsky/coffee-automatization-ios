//
//  DBPositionsViewController.m
//  DoubleB
//
//  Created by Sergey Pronin on 7/31/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "CategoriesAndPositionsTVController.h"

#import "DBSettingsTableViewController.h"

#import "DBBarButtonItem.h"
#import "MBProgressHUD.h"
#import "DBMenu.h"
#import "DBMenuPosition.h"
#import "DBPositionCell.h"
#import "DBCategoryHeaderView.h"
#import "DBCategoryPicker.h"
#import "OrderCoordinator.h"
#import "Venue.h"
#import "DBMenuCategory.h"
#import "DBDropdownTitleView.h"
#import "DBPositionModifiersListModalView.h"
#import "DBSubscriptionManager.h"
#import "NetworkManager.h"

#import "SubscriptionInfoTableViewCell.h"
#import "UIAlertView+BlocksKit.h"
#import "UIViewController+DBCardManagement.h"
#import <BlocksKit/UIControl+BlocksKit.h>

#define TAG_POPUP_OVERLAY 333
#define TAG_PICKER_OVERLAY 444

@interface CategoriesAndPositionsTVController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, DBPositionCellDelegate, DBCategoryHeaderViewDelegate, DBCategoryPickerDelegate, DBSubscriptionManagerProtocol, SubscriptionViewControllerDelegate, DBMenuCategoryDropdownTitleViewDelegate>
@property (strong, nonatomic) NSString *lastVenueId;
@property (strong, nonatomic) NSArray *categories;

@property (strong, nonatomic) NSArray *categoryHeaders;
@property (strong, nonatomic) NSMutableArray *rowsPerSection;

@property (strong, nonatomic) DBDropdownTitleView *titleView;
@property (strong, nonatomic) DBCategoryPicker *categoryPicker;
// so bad, so fucking bad
@property (nonatomic) NSInteger numberOfLoadings;

@end

@implementation CategoriesAndPositionsTVController

+ (instancetype)createViewController {
    return [CategoriesAndPositionsTVController new];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    // Title
    [self setupTitleView];
    
    // Profile button
    self.navigationItem.leftBarButtonItem = [DBBarButtonItem profileItem:self action:@selector(moveToSettings)];
    
    // Order button
    self.navigationItem.rightBarButtonItem = [DBBarButtonItem orderItem:self action:@selector(moveToOrder)];
    
    //styling
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerNib:[UINib nibWithNibName:@"SubscriptionInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"SubscriptionCell"];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(loadMenu:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    self.categoryPicker = [DBCategoryPicker new];
    self.categoryPicker.pickerDelegate = self;
    
    [self subscribeForNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [GANHelper analyzeScreen:@"Menu_screen"];
    [DBSubscriptionManager sharedInstance].delegate = self;
    
    [self loadMenu:nil];
    [self reloadTitleView:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [DBSubscriptionManager sharedInstance].delegate = nil;
    
    [self.categoryPicker hide];
}

- (void)subscribeForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadMenu) name:kDBSubscriptionManagerCategoryIsAvailable object:nil];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadMenu {
    [self loadMenu:nil];
}

- (void)loadMenu:(UIRefreshControl *)refreshControl {
    [GANHelper analyzeEvent:@"menu_update" category:MENU_SCREEN];
    
    void (^menuUpdateHandler)(BOOL, NSArray*) = ^void(BOOL success, NSArray *categories) {
        self.numberOfLoadings -= 1;
        if (!self.numberOfLoadings) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [refreshControl endRefreshing];
        }
        
        if (success) {
            if ([[DBSubscriptionManager sharedInstance] subscriptionCategory]) {
                if ([[DBSubscriptionManager sharedInstance] isEnabled]) {
                    NSMutableArray *dict = [NSMutableArray arrayWithArray:@[[[DBSubscriptionManager sharedInstance] subscriptionCategory]]];
                    [dict addObjectsFromArray:categories];
                    self.categories = dict;
                } else {
                    self.categories = categories;
                }
            } else {
                self.categories = categories;
            }
            
            [self reloadTableView];
            [self reloadTitleView:[self.categories firstObject]];
        }
        
        [self.tableView reloadData];
    };
    
    Venue *venue = [OrderCoordinator sharedInstance].orderManager.venue;
    if (refreshControl) {
        self.numberOfLoadings += 1;
        [[DBMenu sharedInstance] updateMenuForVenue:venue
                                         remoteMenu:menuUpdateHandler];
    } else {
        if(venue.venueId){
            // Load menu for current Venue
            if(!self.lastVenueId || ![self.lastVenueId isEqualToString:venue.venueId]){
                self.lastVenueId = venue.venueId;
                
                self.categories = [[DBMenu sharedInstance] getMenuForVenue:venue];
                
                if ([[DBSubscriptionManager sharedInstance] subscriptionCategory]) {
                    if ([[DBSubscriptionManager sharedInstance] isEnabled]) {
                        NSMutableArray *dict = [NSMutableArray arrayWithArray:@[[[DBSubscriptionManager sharedInstance] subscriptionCategory]]];
                        [dict addObjectsFromArray:self.categories];
                        self.categories = dict;
                    }
                }
            }
        } else {
            // Load whole menu
            self.categories = [[DBMenu sharedInstance] getMenu];
            
            if ([[DBSubscriptionManager sharedInstance] subscriptionCategory]) {
                if ([[DBSubscriptionManager sharedInstance] isEnabled]) {
                    NSMutableArray *dict = [NSMutableArray arrayWithArray:@[[[DBSubscriptionManager sharedInstance] subscriptionCategory]]];
                    [dict addObjectsFromArray:self.categories];
                    self.categories = dict;
                }
            }
        }
        
        
        if (self.categories && [self.categories count] > 0) {
            [self reloadTableView];
        } else {
            if (!self.numberOfLoadings) {
                self.numberOfLoadings += 1;
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            }
            [[DBMenu sharedInstance] updateMenuForVenue:venue
                                             remoteMenu:menuUpdateHandler];
        }
    }
}

- (void)moveToOrder {
    [self.navigationController pushViewController:[DBClassLoader loadNewOrderViewController] animated:YES];
    [GANHelper analyzeEvent:@"order_pressed" category:MENU_SCREEN];
}

- (void)moveToSettings {
    DBSettingsTableViewController *settingsController = [DBClassLoader loadSettingsViewController];
    [self.navigationController pushViewController:settingsController animated:YES];
}

- (void)setupTitleView {
    _titleView = [DBDropdownTitleView new];
    _titleView.delegate = self;
    _titleView.title = NSLocalizedString(@"Меню", nil);
    [self reloadTitleView:nil];
    
    self.navigationItem.titleView = _titleView;
}

- (void)reloadTitleView:(DBMenuCategory *)category {
    if (self.categories.count > 0) {
//        if (category) {
//            _titleView.title = category.name;
//        } else {
//            DBMenuCategory *category = [self currentCategory];
//            if (!category){
//                category = [self.categories firstObject];
//            }
//            _titleView.title = category.name;
//        }
        
        if (self.categories.count == 1)
            _titleView.state = DBDropdownTitleViewStateNone;
        else
            _titleView.state = self.categoryPicker.presented ? DBDropdownTitleViewStateOpened : DBDropdownTitleViewStateClosed;
    } else {
//        _titleView.title = NSLocalizedString(@"Меню", nil);
        _titleView.state = DBDropdownTitleViewStateNone;
    }
}

- (void)pushSubscriptionViewController {
    UIViewController<SubscriptionViewControllerProtocol> *subscriptionVC = [ViewControllerManager subscriptionViewController];
    subscriptionVC.delegate = self;
    [self.navigationController pushViewController:subscriptionVC animated:YES];
}

#pragma mark - SubscriptionViewControllerDelegate methods
- (void)subscriptionViewControllerWillDissappear {
    [self.tableView reloadData];
}

#pragma mark - UITableView methods

- (void)reloadTableView {
    NSMutableArray *headers = [NSMutableArray new];
    for (DBMenuCategory *category in self.categories) {
        DBCategoryHeaderView *headerView = [[DBCategoryHeaderView alloc] initWithMenuCategory:category state:DBCategoryHeaderViewStateFull];
        headerView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, headerView.frame.size.height);
        headerView.delegate = self;
        [headerView changeState:DBCategoryHeaderViewStateCompact animated:NO];
        [headerView setCategoryOpened:YES animated:NO];
        
        [headers addObject:headerView];
    }
    self.categoryHeaders = headers;
    
    self.rowsPerSection = [NSMutableArray new];
    for(DBMenuCategory *category in self.categories)
        [self.rowsPerSection addObject:@([category.positions count])];
    
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
    if ([[DBSubscriptionManager sharedInstance] subscriptionCategory] && section == 0) {
        return [self.rowsPerSection[section] integerValue] + 1;
    } else {
        return [self.rowsPerSection[section] integerValue];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[DBSubscriptionManager sharedInstance] isEnabled] && [[DBSubscriptionManager sharedInstance] subscriptionCategory]) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                SubscriptionInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SubscriptionCell"];
                if ([[DBSubscriptionManager sharedInstance] isAvailable]) {
                    cell.placeholderView.hidden = YES;
                    cell.numberOfCupsLabel.text = [NSString stringWithFormat:@"x %ld", [[DBSubscriptionManager sharedInstance] numberOfAvailableCups]];
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
    DBCategoryHeaderView *header = self.categoryHeaders[section];
    
    return header.viewHeight;
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
    
    if ([[DBSubscriptionManager sharedInstance] isEnabled]) {
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
    if (idxPath.section == 0) {
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

#pragma mark - DBCategoryPickerDelegate

- (void)db_categoryPicker:(DBCategoryPicker *)picker didSelectCategory:(DBMenuCategory *)category{
    NSUInteger section = [self.categories indexOfObject:category];
    
    if(section != NSNotFound && section < [self.categories count]){
        [self scrollTableViewToSection:section];
        
        [self.categoryPicker hide];
        [self reloadTitleView:category];
    }
    
    [GANHelper analyzeEvent:@"category_spinner_selected" label:category.categoryId category:MENU_SCREEN];
}

#pragma mark - DBMenuCategoryDropdownTitleViewDelegate

- (void)db_dropdownTitleClick:(DBDropdownTitleView *)view {
    if(self.categoryPicker.presented){
        [self.categoryPicker hide];
    } else {
        if (self.categories.count > 0){
            [self.categoryPicker configureWithCurrentCategory:[self currentCategory] categories:self.categories];
            
            CGFloat offset = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
            [self.categoryPicker showOnView:self.navigationController.view appearance:DBPopupAppearanceModal transition:DBPopupTransitionTop offset:offset];
            [self.navigationController.view bringSubviewToFront:self.navigationController.navigationBar];
        }
    }
    
    [self reloadTitleView:nil];
    
    [GANHelper analyzeEvent:@"category_spinner_click" category:MENU_SCREEN];
}

#pragma mark - DBSubscriberManagerDelegate 

- (void)currentSubscriptionStateChanged {
    if ([[DBSubscriptionManager sharedInstance] isEnabled]) {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - DBCategoryPickerDelegate

- (DBMenuCategory *)currentCategory {
    UITableViewCell *firstVisibleCell;
    if (self.tableView.visibleCells.count > 1) { // Choose second cell as section header hide cell for previous section
        firstVisibleCell = self.tableView.visibleCells[1];
    } else {
        firstVisibleCell = self.tableView.visibleCells.firstObject;
    }
    
    DBMenuCategory *topCategory;
    if(firstVisibleCell){
        NSInteger topSection = [[self.tableView indexPathForCell:firstVisibleCell] section];
        topCategory = [self.categories objectAtIndex:topSection];
    } else {
        topCategory = [self.categories objectAtIndex:0];
    }
    
    return topCategory;
}

- (void)db_componentWillDismiss:(DBPopupComponent *)component {
    [GANHelper analyzeEvent:@"category_spinner_closed" category:MENU_SCREEN];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [GANHelper analyzeEvent:@"menu_scroll" category:MENU_SCREEN];
}

@end
