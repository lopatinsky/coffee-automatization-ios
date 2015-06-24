//
//  DBPositionsViewController.m
//  DoubleB
//
//  Created by Sergey Pronin on 7/31/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBPositionsViewController.h"
#import "DBBarButtonItem.h"
#import "DBPositionViewController.h"
#import "MBProgressHUD.h"
#import "DBMenu.h"
#import "DBMenuPosition.h"
#import "DBPositionCell.h"
#import "DBCategoryHeaderView.h"
#import "DBCategoryPicker.h"
#import "OrderManager.h"
#import "Venue.h"
#import "Compatibility.h"
#import "DBNewOrderViewController.h"
#import "DBMenuCategory.h"
#import "DBPositionScrollViewController.h"

#import "UIAlertView+BlocksKit.h"
#import "UIViewController+DBCardManagement.h"
#import <BlocksKit/UIControl+BlocksKit.h>

#define TAG_POPUP_OVERLAY 333
#define TAG_PICKER_OVERLAY 444

@interface DBPositionsViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, DBPositionCellDelegate, DBCatecoryHeaderViewDelegate, DBCategoryPickerDelegate>
@property (strong, nonatomic) NSString *lastVenueId;
@property (strong, nonatomic) NSArray *categories;

@property (strong, nonatomic) NSArray *categoryHeaders;
@property (strong, nonatomic) NSMutableArray *rowsPerSection;

@property (strong, nonatomic) DBCategoryPicker *categoryPicker;
@end

@implementation DBPositionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = NSLocalizedString(@"Меню", nil);
    self.navigationItem.leftBarButtonItem = [[DBBarButtonItem alloc] initWithViewController:self action:@selector(moveBack)];
    
    //styling
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [UIView new];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(loadMenu:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    self.categoryPicker = [DBCategoryPicker new];
    self.categoryPicker.delegate = self;
    
    [self setupCategorySelectionBarButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [GANHelper analyzeScreen:@"Menu_screen"];

    [self loadMenu:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self hideCategoryPicker];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadMenu:(UIRefreshControl *)refreshControl{
    [GANHelper analyzeEvent:@"menu_update" category:MENU_SCREEN];
    void (^menuUpdateHandler)(BOOL, NSArray*) = ^void(BOOL success, NSArray *categories) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [refreshControl endRefreshing];
        
        if (success) {
            self.categories = categories;
            
            [self reloadTableView];
        }
        
        [self.tableView reloadData];
    };
    
    if(refreshControl){
        [[DBMenu sharedInstance] updateMenuForVenue:[OrderManager sharedManager].venue
                                         remoteMenu:menuUpdateHandler];
    } else {
        if([OrderManager sharedManager].venue.venueId){
            // Load menu for current Venue
            if(!self.lastVenueId || ![self.lastVenueId isEqualToString:[OrderManager sharedManager].venue.venueId]){
                self.lastVenueId = [OrderManager sharedManager].venue.venueId;
                
                self.categories = [[DBMenu sharedInstance] getMenuForVenue:[OrderManager sharedManager].venue];
            }
        } else {
            // Load whole menu
            self.categories = [[DBMenu sharedInstance] getMenu];
        }
        
            
        if (self.categories && [self.categories count] > 0){
            [self reloadTableView];
        } else {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[DBMenu sharedInstance] updateMenuForVenue:[OrderManager sharedManager].venue
                                             remoteMenu:menuUpdateHandler];
        }
    }
}

- (void)moveBack {
    [self.navigationController popViewControllerAnimated:YES];
    [GANHelper analyzeEvent:@"order_pressed" category:MENU_SCREEN];
}

- (void)cartAddPositionFromCell:(DBPositionCell *)cell{
    [[OrderManager sharedManager] addPosition:cell.position];
    
    [GANHelper analyzeEvent:@"product_added" label:cell.position.positionId category:MENU_SCREEN];
}

- (void)setupCategorySelectionBarButton{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 20)];
    button.backgroundColor = [UIColor clearColor];
    [button setTitle:@"" forState:UIControlStateNormal];
    
    UIImageView *imageView = [UIImageView new];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView templateImageWithName:@"category_selection_icon" tintColor:[UIColor whiteColor]];
    
    [button addSubview:imageView];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [imageView alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:button];
    
    [button bk_addEventHandler:^(id sender) {
        if(self.categoryPicker.isOpened){
            [self hideCategoryPicker];
        } else {
            [self showCatecoryPickerFromRect:self.navigationController.navigationBar.frame onView:self.navigationController.view];
        }
        
        [GANHelper analyzeEvent:@"category_spinner_click" category:MENU_SCREEN];
    } forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}


#pragma mark - UITableView methods

- (void)reloadTableView{
    NSMutableArray *headers = [NSMutableArray new];
    for (DBMenuCategory *category in self.categories){
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

//- (void)openTableSection:(NSInteger)section{
//    DBCategoryHeaderView *headerView = self.categoryHeaders[section];
//    
//    NSMutableArray *indexPaths = [NSMutableArray new];
//    for(int i = 0; i < [headerView.category.positions count]; i++)
//        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:section]];
//    
//    self.rowsPerSection[section] = @([headerView.category.positions count]);
//    
//    [headerView changeState:DBCategoryHeaderViewStateCompact animated:YES];
//    [headerView setCategoryOpened:YES animated:YES];
//    
//    // Animate
//    [self.tableView beginUpdates];
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
//    
//    // Animate Scroll to selected section
//    // Dispatch helps not to get crash
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self scrollTableViewToSection:section];
//    });
//    [self.tableView endUpdates];
//}
//
//- (void)closeTableViewSection:(NSInteger)section{
//    DBCategoryHeaderView *headerView = self.categoryHeaders[section];
//    
//    NSMutableArray *indexPaths = [NSMutableArray new];
//    for(int i = 0; i < [headerView.category.positions count]; i++)
//        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:section]];
//    
//    self.rowsPerSection[section] = @0;
//    
//    [headerView changeState:DBCategoryHeaderViewStateFull animated:YES];
//    [headerView setCategoryOpened:NO animated:YES];
//    
//    [self.tableView beginUpdates];
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
//    [self.tableView endUpdates];
//}

- (void)scrollTableViewToSection:(NSInteger)section{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.categories count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.rowsPerSection[section] integerValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBPositionCell *cell;
    
    DBMenuCategory *category = [self.categories objectAtIndex:indexPath.section];
    if(category.categoryWithImages){
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
    [cell configureWithPosition:position];
    cell.delegate = self;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    DBMenuCategory *category = [self.categories objectAtIndex:indexPath.section];
    if(category.categoryWithImages){
        return 120;
    } else {
        return 44;
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
    
    DBPositionCell *cell = (DBPositionCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    DBMenuPosition *position = cell.position;

    DBPositionViewController *positionVC = [[DBPositionViewController alloc] initWithPosition:position mode:DBPositionViewControllerModeMenuPosition];
    positionVC.parentNavigationController = self.navigationController;
    [self.navigationController pushViewController:positionVC animated:YES];
    
//    DBPositionViewController *positionVC = [[DBPositionViewController alloc] initWithPosition:position mode:DBPositionViewControllerModeMenuPosition];
//    [self.navigationController pushViewController:positionVC animated:YES];
    
    [GANHelper analyzeEvent:@"product_selected" label:position.positionId category:MENU_SCREEN];
}

#pragma mark - DBPositionCellDelegate

- (void)positionCellDidOrder:(DBPositionCell *)cell{
    [self cartAddPositionFromCell:cell];
    
    [GANHelper analyzeEvent:@"price_pressed" label:cell.position.positionId category:MENU_SCREEN];
}

//#pragma mark - DBCatecoryHeaderViewDelegate
//
//- (void)db_categoryHeaderViewDidSelect:(DBCategoryHeaderView *)headerView{
//    NSUInteger section = [self.categories indexOfObject:headerView.category];
//    
//    if(section != NSNotFound && section < [self.categories count]){
//        if([self.rowsPerSection[section] intValue] == 0){
//            [self openTableSection:section];
//        } else {
//            [self closeTableViewSection:section];
//        }
//    }
//    
//    [self hideCategoryPicker];
//}

#pragma mark - DBCategoryPicker methods

- (void)showCatecoryPickerFromRect:(CGRect)fromRect onView:(UIView *)onView{
    [GANHelper analyzeEvent:@"category_spinner_click" category:MENU_SCREEN];
    if(!self.categoryPicker.isOpened){
        UITableViewCell *firstVisibleCell = [[self.tableView visibleCells] firstObject];
        DBMenuCategory *topCategory;
        if(firstVisibleCell){
            NSInteger topSection = [[self.tableView indexPathForCell:firstVisibleCell] section];
            topCategory = [self.categories objectAtIndex:topSection];
        } else {
            topCategory = [self.categories objectAtIndex:0];
        }

        [self.categoryPicker configureWithCurrentCategory:topCategory categories:self.categories];
        [self.categoryPicker openedOnView:onView];
        
        CGRect rect = [onView convertRect:fromRect toView:self.navigationController.view];
        
        CGRect pickerRect = self.categoryPicker.frame;
        pickerRect.size.width = self.tableView.frame.size.width;
        rect.origin.y += rect.size.height;
        pickerRect.origin.y = rect.origin.y - pickerRect.size.height;
        
        self.categoryPicker.frame = pickerRect;
        [self.navigationController.view insertSubview:self.categoryPicker belowSubview:self.navigationController.navigationBar];
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect pickerRect = self.categoryPicker.frame;
            pickerRect.origin.y = rect.origin.y;
           
            self.categoryPicker.frame = pickerRect;
        }];
    }
}

- (void)hideCategoryPicker{
    [GANHelper analyzeEvent:@"category_spinner_closed" category:MENU_SCREEN];
    if(self.categoryPicker.isOpened){
        [self.categoryPicker closed];
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect pickerRect = self.categoryPicker.frame;
            pickerRect.origin.y = pickerRect.origin.y - pickerRect.size.height;
            
            self.categoryPicker.frame = pickerRect;
        } completion:^(BOOL finished) {
            [self.categoryPicker removeFromSuperview];
        }];
    }
}

#pragma mark - DBCategoryPickerDelegate

- (void)db_categoryPicker:(DBCategoryPicker *)picker didSelectCategory:(DBMenuCategory *)category{
    NSUInteger section = [self.categories indexOfObject:category];
    
    if(section != NSNotFound && section < [self.categories count]){
//        [self openTableSection:section];
        [self scrollTableViewToSection:section];
        [self hideCategoryPicker];
    }
    
    [GANHelper analyzeEvent:@"category_spinner_selected" label:category.categoryId category:MENU_SCREEN];
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self hideCategoryPicker];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [GANHelper analyzeEvent:@"menu_scroll" category:MENU_SCREEN];
}


@end
