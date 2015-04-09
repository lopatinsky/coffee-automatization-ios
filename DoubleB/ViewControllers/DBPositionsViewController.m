//
//  DBPositionsViewController.m
//  DoubleB
//
//  Created by Sergey Pronin on 7/31/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBPositionsViewController.h"
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

#import "UIAlertView+BlocksKit.h"
#import "UIViewController+DBCardManagement.h"
#import <BlocksKit/UIGestureRecognizer+BlocksKit.h>
#import <BlocksKit/UIControl+BlocksKit.h>

#define TAG_POPUP_OVERLAY 333
#define TAG_PICKER_OVERLAY 444

@interface DBPositionsViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, DBPositionCellDelegate, DBCatecoryHeaderViewDelegate, DBCategoryPickerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTableViewTopSpace;

@property (strong, nonatomic) NSString *lastVenueId;
@property (strong, nonatomic) NSArray *categories;

@property (strong, nonatomic) NSArray *categoryHeaders;
@property (strong, nonatomic) NSMutableArray *rowsPerSection;

@property (strong, nonatomic) DBCategoryPicker *categoryPicker;

//@property (nonatomic, strong) UIPickerView *pickerView;
//@property (nonatomic, strong) UIView *viewHolderPicker;
//@property (nonatomic, strong) DBPositionCellOld *currentlyModifyingPositionCell;
@end

@implementation DBPositionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = NSLocalizedString(@"Меню", nil);
    
    //styling
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.rowHeight = 120;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [UIView new];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    CGFloat topInset = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height;
    self.constraintTableViewTopSpace.constant = topInset;
    
    self.tableView.delegate = self;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(loadMenu:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    self.categoryPicker = [DBCategoryPicker new];
    self.categoryPicker.delegate = self;
    
    [self setupCategorySelectionBarButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [GANHelper analyzeScreen:@"Menu_screen"];

    [self loadMenu:nil];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadMenu:(UIRefreshControl *)refreshControl{
    if(!self.lastVenueId || ![self.lastVenueId isEqualToString:[OrderManager sharedManager].venue.venueId]){
        self.lastVenueId = [OrderManager sharedManager].venue.venueId;
        
        self.categories = [[DBMenu sharedInstance] getMenuForVenue:[OrderManager sharedManager].venue
                                                        remoteMenu:^(BOOL success, NSArray *categories) {
                                                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                            [refreshControl endRefreshing];
                                                            
                                                            if (success) {
                                                                self.categories = categories;
                                                                
                                                                [self reloadTableView];
                                                            }
                                                            
                                                            [self.tableView reloadData];
                                                        }];
        if (self.categories && [self.categories count] > 0){
            [self reloadTableView];
        } else {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }
    }
}

- (void)clickOrder:(id)sender {
    [GANHelper analyzeEvent:@"order_basket_click"
                      label:[NSString stringWithFormat:@"%lu", (unsigned long) [OrderManager sharedManager].positionsCount]
                   category:@"Menu_screen"];

    DBNewOrderViewController *newOrderViewController = [DBNewOrderViewController new];
    newOrderViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:newOrderViewController animated:YES];
}

- (void)cartAddPositionFromCell:(DBPositionCell *)cell{
    [[OrderManager sharedManager] addPosition:cell.position];
}

- (void)setupCategorySelectionBarButton{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
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
        [headers addObject:headerView];
    }
    self.categoryHeaders = headers;
    
    self.rowsPerSection = [NSMutableArray new];
    for(DBMenuCategory *category in self.categories)
        [self.rowsPerSection addObject:@(0)];
    
    [self.tableView reloadData];
}

- (void)openTableSection:(NSInteger)section{
    DBCategoryHeaderView *headerView = self.categoryHeaders[section];
    
    NSMutableArray *indexPaths = [NSMutableArray new];
    for(int i = 0; i < [headerView.category.positions count]; i++)
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    
    self.rowsPerSection[section] = @([headerView.category.positions count]);
    
    [headerView changeState:DBCategoryHeaderViewStateCompact animated:YES];
    
    // Animate
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
    
    // Animate Scroll to selected section
    // Dispatch helps not to get crash
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scrollTableViewToSection:section];
    });
    [self.tableView endUpdates];
}

- (void)closeTableViewSection:(NSInteger)section{
    DBCategoryHeaderView *headerView = self.categoryHeaders[section];
    
    NSMutableArray *indexPaths = [NSMutableArray new];
    for(int i = 0; i < [headerView.category.positions count]; i++)
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    
    self.rowsPerSection[section] = @0;
    
    [headerView changeState:DBCategoryHeaderViewStateFull animated:YES];
    
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

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
    DBPositionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBPositionCell"];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"DBPositionCell" owner:self options:nil][0];
        cell.delegate = self;
    }
    DBMenuPosition *position = ((DBMenuCategory *)self.categories[indexPath.section]).positions[indexPath.row];
    [cell configureWithPosition:position];
    
    return cell;
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
    
    [GANHelper analyzeEvent:@"item_click"
                      label:position.name
                   category:@"Menu_screen"];
    
    
    DBPositionViewController *positionVC = [[DBPositionViewController alloc] initWithPosition:position];
    [self.navigationController pushViewController:positionVC animated:YES];
}

#pragma mark - DBPositionCellDelegate

- (void)positionCellDidOrder:(DBPositionCell *)cell{
    [self cartAddPositionFromCell:cell];
}

#pragma mark - DBCatecoryHeaderViewDelegate

- (void)db_categoryHeaderViewDidSelect:(DBCategoryHeaderView *)headerView{
    NSUInteger section = [self.categories indexOfObject:headerView.category];
    
    if(section != NSNotFound && section < [self.categories count]){
        if([self.rowsPerSection[section] intValue] == 0){
            [self openTableSection:section];
        } else {
            [self closeTableViewSection:section];
        }
    }
    
    [self hideCategoryPicker];
}

#pragma mark - DBCategoryPicker methods

- (void)showCatecoryPickerFromRect:(CGRect)fromRect onView:(UIView *)onView{
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
        [self openTableSection:section];
        [self hideCategoryPicker];
    }
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [GANHelper analyzeEvent:@"scroll" category:@"Menu_screen"];
    
    [self hideCategoryPicker];
}


@end
