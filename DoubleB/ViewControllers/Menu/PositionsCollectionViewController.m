//
//  PositionsCollectionViewController.m
//  
//
//  Created by Balaban Alexander on 15/07/15.
//
//

#import "PositionsCollectionViewController.h"
#import "PositionCollectionViewCell.h"

#import "DBBarButtonItem.h"
#import "DBCategoryPicker.h"
#import "DBCategoryHeaderView.h"
#import "DBMenu.h"
#import "DBMenuCategory.h"
#import "DBPositionCell.h"
#import "OrderManager.h"
#import "Venue.h"

#import "MBProgressHUD.h"
#import <BlocksKit/UIControl+BlocksKit.h>

@interface PositionsCollectionViewController () <UICollectionViewDelegateFlowLayout, DBPositionCellDelegate, DBCategoryHeaderViewDelegate, DBCategoryPickerDelegate>

@property (nonatomic, strong) NSString *lastVenueId;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSArray *categoryHeaders;
@property (nonatomic, strong) NSMutableArray *rowsPerSection;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) DBCategoryPicker *categoryPicker;

@end

@implementation PositionsCollectionViewController

static NSString * const reuseIdentifier = @"PositionCollectionCell";

#pragma mark - Life-Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.collectionView.alwaysBounceVertical = YES;
    
    self.categoryPicker = [DBCategoryPicker new];
    self.categoryPicker.delegate = self;
    [self setupCategorySelectionBarButton];
    [self initializeViews];
}

- (void)initializeViews {
    [self.collectionView registerClass:[PositionCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    self.navigationItem.title = NSLocalizedString(@"Меню", nil);
    self.navigationItem.leftBarButtonItem = [[DBBarButtonItem alloc] initWithViewController:self action:@selector(moveBack)];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor grayColor];
    [self.refreshControl addTarget:self action:@selector(loadMenu:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [GANHelper analyzeScreen:@"Menu_screen"];
    
    [self loadMenu:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self hideCategoryPicker];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - User methods
- (void)moveBack {
    [self.navigationController popViewControllerAnimated:YES];
    [GANHelper analyzeEvent:@"order_pressed" category:MENU_SCREEN];
}

- (void)setupCategorySelectionBarButton {
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

- (void)reloadCollectionView {
    NSMutableArray *headers = [NSMutableArray new];
    for (DBMenuCategory *category in self.categories) {
        DBCategoryHeaderView *headerView = [[DBCategoryHeaderView alloc] initWithMenuCategory:category state:DBCategoryHeaderViewStateFull];
        headerView.frame = CGRectMake(0, 0, self.collectionView.frame.size.width, headerView.frame.size.height);
        headerView.delegate = self;
        [headerView changeState:DBCategoryHeaderViewStateCompact animated:NO];
        [headerView setCategoryOpened:YES animated:NO];
        
        [headers addObject:headerView];
    }
    self.categoryHeaders = headers;
    
    self.rowsPerSection = [NSMutableArray new];
    for (DBMenuCategory *category in self.categories) {
        [self.rowsPerSection addObject:@([category.positions count])];
    }
    
    [self.collectionView reloadData];
}

- (void)hideCategoryPicker {
    [GANHelper analyzeEvent:@"category_spinner_closed" category:MENU_SCREEN];
    if (self.categoryPicker.isOpened){
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

- (void)loadMenu:(UIRefreshControl *)refreshControl{
    [GANHelper analyzeEvent:@"menu_update" category:MENU_SCREEN];
    void (^menuUpdateHandler)(BOOL, NSArray*) = ^void(BOOL success, NSArray *categories) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [refreshControl endRefreshing];
        
        if (success) {
            self.categories = categories;
            [self reloadCollectionView];
        } else {
            [self.collectionView reloadData];
        }
    };
    
    if (self.refreshControl) {
        [[DBMenu sharedInstance] updateMenuForVenue:[OrderManager sharedManager].venue
                                         remoteMenu:menuUpdateHandler];
    } else {
        if ([OrderManager sharedManager].venue.venueId) {
            if (!self.lastVenueId || ![self.lastVenueId isEqualToString:[OrderManager sharedManager].venue.venueId]) {
                self.lastVenueId = [OrderManager sharedManager].venue.venueId;
                self.categories = [[DBMenu sharedInstance] getMenuForVenue:[OrderManager sharedManager].venue];
            }
        } else {
            self.categories = [[DBMenu sharedInstance] getMenu];
        }
        
        if (self.categories && [self.categories count] > 0) {
            [self reloadCollectionView];
        } else {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[DBMenu sharedInstance] updateMenuForVenue:[OrderManager sharedManager].venue
                                             remoteMenu:menuUpdateHandler];
        }
    }
}

- (void)scrollCollectionViewToSection:(NSInteger)section {
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.categories count];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.rowsPerSection[section] integerValue];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PositionCollectionViewCell *cell = (PositionCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    DBMenuPosition *position = ((DBMenuCategory *)self.categories[indexPath.section]).positions[indexPath.row];
    [cell configureWithPosition:position];
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 6;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 6;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = ([[UIScreen mainScreen] bounds].size.width - 18.0 )/ 2.0;
    CGFloat height = width * 1.25;
    return CGSizeMake(width, height);
}

#pragma mark - DBCategoryPicker methods
- (void)showCatecoryPickerFromRect:(CGRect)fromRect onView:(UIView *)onView{
    [GANHelper analyzeEvent:@"category_spinner_click" category:MENU_SCREEN];
    if(!self.categoryPicker.isOpened){
        UICollectionViewCell *firstVisibleCell = [[self.collectionView visibleCells] firstObject];
        DBMenuCategory *topCategory;
        if (firstVisibleCell) {
            NSInteger topSection = [[self.collectionView indexPathForCell:firstVisibleCell] section];
            topCategory = [self.categories objectAtIndex:topSection];
        } else {
            topCategory = [self.categories objectAtIndex:0];
        }
        
        [self.categoryPicker configureWithCurrentCategory:topCategory categories:self.categories];
        [self.categoryPicker openedOnView:onView];
        
        CGRect rect = [onView convertRect:fromRect toView:self.navigationController.view];
        
        CGRect pickerRect = self.categoryPicker.frame;
        pickerRect.size.width = self.collectionView.frame.size.width;
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

#pragma mark - DBCategoryPickerDelegate
- (void)db_categoryPicker:(DBCategoryPicker *)picker didSelectCategory:(DBMenuCategory *)category{
    NSUInteger section = [self.categories indexOfObject:category];
    
    if (section != NSNotFound && section < [self.categories count]) {
        [self scrollCollectionViewToSection:section];
        [self hideCategoryPicker];
    }
    
    [GANHelper analyzeEvent:@"category_spinner_selected" label:category.categoryId category:MENU_SCREEN];
}


#pragma mark - PositionsViewControllerProtocol
+ (instancetype)createViewController {
    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat width = ([[UIScreen mainScreen] bounds].size.width - 18.0)/ 2.0;
    CGFloat height = width * 1.25;
    [aFlowLayout setItemSize:CGSizeMake(width, height)];
    [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    return [[PositionsCollectionViewController alloc] initWithCollectionViewLayout:aFlowLayout];
}

@end
