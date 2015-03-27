//
//  DBPositionsViewController.m
//  DoubleB
//
//  Created by Sergey Pronin on 7/31/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <BlocksKit/UIGestureRecognizer+BlocksKit.h>
#import "DBPositionsViewController.h"
#import "MenuHelper.h"
#import "MBProgressHUD.h"
#import "Position.h"
#import "MenuPositionExtension.h"
#import "DBPositionCell.h"
#import "OrderManager.h"
#import "Venue.h"
#import "Compatibility.h"
#import "IHSecureStore.h"
#import "DBHTMLViewController.h"
#import "UIAlertView+BlocksKit.h"
#import "DBNewOrderViewController.h"
#import "DBCardsViewController.h"
#import "DBSettingsTableViewController.h"
#import "DBMastercardPromo.h"
#import "DBAdvertViewController.h"
#import "DBMastercardAdvertProgressView.h"
#import "DBMastercardAdvertPopup.h"
#import "DBMastercardAdView.h"
#import "DBMastercardPromo.h"
#import "IHPaymentManager.h"
#import "DBMenuCategory.h"

#import "UIViewController+DBCardManagement.h"

#define TAG_POPUP_OVERLAY 333
#define TAG_PICKER_OVERLAY 444

@interface DBPositionsViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView; 
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintSegmentedControlTopSpace;

@property (strong, nonatomic) DBMastercardPromo *mastercardPromo;
@property (strong, nonatomic) UIView *promoViewCurrentlyVisible;
@property (nonatomic) BOOL isAppeared;

@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIView *viewHolderPicker;
@property (nonatomic, strong) DBPositionCell *currentlyModifyingPositionCell;
@property (nonatomic) NSInteger currentlySelectedExtensionNumber;
@property (nonatomic) unsigned int currentSegmentIndex;
@end

@implementation DBPositionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isAppeared = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = NSLocalizedString(@"Меню", nil);

    //styling
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.height, 0);
    self.tableView.rowHeight = 55;
    self.tableView.tableFooterView = [UIView new];
    
    self.tableView.delegate = self;
    
    double topY = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height + 3;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.constraintSegmentedControlTopSpace.constant = topY;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(loadMenu:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    [self setupPicker];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [GANHelper analyzeScreen:@"Menu_screen"];

    self.currentSegmentIndex = [[NSString stringWithFormat:@"%d", self.segmentedControl.selectedSegmentIndex] intValue];
    [self refreshSegmentedControl];
    [self loadMenu:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    self.isAppeared = YES;
}
- (void)viewDidDisappear:(BOOL)animated{
    self.isAppeared = NO;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadMenu:(UIRefreshControl *)refreshControl{
    if (![[MenuHelper sharedHelper] getMenuForVenue:[OrderManager sharedManager].venue.venueId completionHandler:^(id response) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [refreshControl endRefreshing];
        
        if (response) {
            self.categories = [NSMutableArray new];
            for (DBMenuCategory *category in response) {
                [self.categories addObject:category];
            }
        }
        [self refreshSegmentedControl];
        self.positions = [NSMutableArray new];
        
        if ([self.categories count] != 0) {
            for (Position *position in ((DBMenuCategory *)self.categories[self.currentSegmentIndex]).items) {
                [self.positions addObject:position];
            }
        }
        
        [self.tableView reloadData];
    }]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
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

- (void)cartAddPositionFromCell:(DBPositionCell *)cell withSelectedExtNumber:(NSNumber *)extNumber{
    NSInteger k;
    if(extNumber){
        k = [[OrderManager sharedManager] addPosition:cell.position withExt:cell.position.exts[extNumber.intValue]];
    } else {
        k = [[OrderManager sharedManager] addPosition:cell.position];
    }
    
    //animation
    CGRect rect = cell.frame;
    rect = [self.tableView convertRect:rect toView:self.navigationController.view];
    int size = 12;
    int originX = cell.plusLabel.frame.origin.x + cell.plusLabel.frame.size.width / 2 - size / 2;
    int originY = rect.origin.y + rect.size.height / 2 - size / 2;
    //TODO: make UIView subclass and override drawRect to draw circle, @see UIBezierPath
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(originX, originY, size, size)];
    view.layer.cornerRadius = size / 2.f;
    view.layer.masksToBounds = YES;
    view.backgroundColor = [UIColor db_blueColor];
    
    [self.navigationController.view addSubview:view];
    
    cell.plusLabel.alpha = 0;
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         view.transform = CGAffineTransformMakeScale(2, 2);
                     }
                     completion:^(BOOL finished) {
                         [view removeFromSuperview];
                     }];
    
    [UIView animateWithDuration:0.2
                          delay:0.1
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         view.alpha = 0;
                         cell.plusLabel.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         [view removeFromSuperview];
                     }];
    
    // Analytics
    if([cell.position.exts count] > 0){
        [GANHelper analyzeEvent:@"ext_selected"
                          label:[NSString stringWithFormat:@"%@ (%@)", cell.position.title,
                                 [cell.position extNameAtIndex:[extNumber intValue]]]
                       category:@"Menu_screen"];
    }
}

#pragma mark - UISegmentedControl
- (IBAction)changeCategory:(UISegmentedControl *)sender {
    self.currentSegmentIndex = [[NSString stringWithFormat:@"%d", sender.selectedSegmentIndex] intValue];
    self.positions = [NSMutableArray new];
    for (Position *position in ((DBMenuCategory *)self.categories[self.currentSegmentIndex]).items) {
        [self.positions addObject:position];
    }
    [self.tableView reloadData];
}

- (void) refreshSegmentedControl {
    if ([self.categories count] > 1) {
        [self.segmentedControl removeAllSegments];
        int index = 0;
        for (DBMenuCategory *menu in self.categories) {
            [self.segmentedControl insertSegmentWithTitle:menu.categoryName atIndex:index animated:NO];
            ++index;
        }
        self.segmentedControl.selectedSegmentIndex = 0;
        self.segmentedControl.hidden = NO;
    } else {
        self.segmentedControl.hidden = YES;
    }
}

#pragma mark - methods for picker

- (void)setupPicker{
    self.pickerView = [UIPickerView new];
    self.viewHolderPicker = [UIView new];
    
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    self.pickerView.backgroundColor = [UIColor db_backgroundColor];
    
    self.viewHolderPicker.frame = self.pickerView.bounds;
    self.viewHolderPicker.backgroundColor = [UIColor db_backgroundColor];
    [self.viewHolderPicker addSubview:self.pickerView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.viewHolderPicker.frame.size.width, 45)];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"Варианты";
    [self.viewHolderPicker addSubview:titleLabel];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:NSLocalizedString(@"Готово", nil) forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor db_blueColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickPickerDone:) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(self.viewHolderPicker.frame.size.width - 50 - 10, 0, 50, 45);
    btn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    [self.viewHolderPicker addSubview:btn];
}

- (void)showPicker {
    UIImage *snapshot = [self.tabBarController.view snapshotImage];
    UIImageView *overlay = [[UIImageView alloc] initWithFrame:self.tabBarController.view.bounds];
    overlay.image = [snapshot applyBlurWithRadius:5 tintColor:[UIColor colorWithWhite:0.3 alpha:0.6] saturationDeltaFactor:1.5 maskImage:nil];
    overlay.alpha = 0;
    overlay.tag = TAG_PICKER_OVERLAY;
    overlay.userInteractionEnabled = YES;
    [overlay addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePicker:)]];
    [self.tabBarController.view addSubview:overlay];
    
    CGRect rect = self.viewHolderPicker.frame;
    rect.origin.y = self.tabBarController.view.bounds.size.height;
    self.viewHolderPicker.frame = rect;
    
    [overlay addSubview:self.viewHolderPicker];
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.viewHolderPicker.frame;
        frame.origin.y -= self.viewHolderPicker.bounds.size.height;
        self.viewHolderPicker.frame = frame;
        
        overlay.alpha = 1;
    }];
    
    [GANHelper analyzeEvent:@"ext_picker_show" category:@"Menu_screen"];
}

- (void)hidePicker:(id)sender {    
    UIView *overlay = [self.tabBarController.view viewWithTag:TAG_PICKER_OVERLAY];
    
    [UIView animateWithDuration:0.2 animations:^{
        overlay.alpha = 0;
        CGRect rect = self.viewHolderPicker.frame;
        rect.origin.y = self.tabBarController.view.bounds.size.height;
        self.viewHolderPicker.frame = rect;
    } completion:^(BOOL f){
        [overlay removeFromSuperview];
        [self.viewHolderPicker removeFromSuperview];
    }];
    
    [GANHelper analyzeEvent:@"ext_picker_hide" category:@"Menu_screen"];
}

- (IBAction)clickPickerDone:(id)sender{
    [self hidePicker:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self cartAddPositionFromCell:self.currentlyModifyingPositionCell withSelectedExtNumber:@(self.currentlySelectedExtensionNumber)];
    });
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.currentlyModifyingPositionCell.position.exts count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    MenuPositionExtension *ext = self.currentlyModifyingPositionCell.position.exts[row];
    return [NSString stringWithFormat:@"%@ %@ руб.", ext.extName, ext.extPrice];
}

#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.currentlySelectedExtensionNumber = row;
    
    [GANHelper analyzeEvent:@"ext_picker_scroll" category:@"Menu_screen"];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.positions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBPositionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBPositionCell"];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"DBPositionCell" owner:self options:nil][0];
    }
    Position *position = self.positions[indexPath.row];
    //    Position *position = ((NewMenu *)self.positions[0]).items[indexPath.row];
    cell.position = position;
    //    NSLog(@"position %@", ((DBMenuCategory *)position).categoryName);
    //    NSLog(@"position.title %@", position.title);
    cell.positionTitleLabel.text = position.title;
    cell.plusImageView.hidden = YES;
    cell.plusLabel.hidden = NO;
    
    cell.plusLabel.text = [NSString stringWithFormat:@"%@ руб.", position.price];
    cell.plusLabel.textColor = [UIColor db_blueColor];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DBPositionCell *cell = (DBPositionCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    Position *position = cell.position;
    
    [GANHelper analyzeEvent:@"item_click"
                      label:cell.position.title
                   category:@"Menu_screen"];
    
    // Position from favourites
    if(indexPath.section == 0 && tableView.numberOfSections == 4){
        if([position.exts count] > 0){
            [self cartAddPositionFromCell:cell withSelectedExtNumber:@(0)];
        } else {
            [self cartAddPositionFromCell:cell withSelectedExtNumber:nil];
        }
    } else {
        if ([position.exts count] > 0){
            self.currentlyModifyingPositionCell = cell;
            [self showPicker];
            [self.pickerView reloadAllComponents];
        } else {
            [self cartAddPositionFromCell:cell withSelectedExtNumber:nil];
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [GANHelper analyzeEvent:@"scroll" category:@"Menu_screen"];
}


@end
