//
//  DBNewOrderViewController.m
//  DoubleB
//
//  Created by Balaban Alexander on 31/07/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBNewOrderViewController.h"
#import "DBNewOrderBonusesView.h"
#import "DBNewOrderTotalView.h"
#import "DBNewOrderViewHeader.h"
#import "DBNewOrderAdditionalInfoView.h"
#import "DBNewOrderNDAView.h"
#import "DBNewOrderViewFooter.h"
#import "DBServerAPI.h"
#import "IHSecureStore.h"
#import "DBAPIClient.h"
#import "MBProgressHUD.h"
#import "OrderManager.h"
#import "Order.h"
#import "DBMenuPosition.h"
#import "DBMenuBonusPosition.h"
#import "OrderItem.h"
#import "Venue.h"
#import "Compatibility.h"
#import "LocationHelper.h"
#import "IHPaymentManager.h"
#import "DBPromoManager.h"
#import "DBNewOrderViewHeader.h"
#import "DBVenuesTableViewController.h"
#import "DBCardsViewController.h"
#import "DBCommentViewController.h"
#import "CoreDataHelper.h"
#import "DBProfileViewController.h"
#import "DBOrdersTableViewController.h"
#import "DBHTMLViewController.h"
#import "DBMastercardPromo.h"
#import "DBOrderItemCell.h"
#import "DBOrderItemNotesCell.h"
#import "Reachability.h"
#import "DBTabBarController.h"
#import "DBTimePickerView.h"
#import "DBClientInfo.h"
#import "DBSettingsTableViewController.h"
#import "DBPositionsViewController.h"
#import "DBBonusPositionsViewController.h"
#import "DBBeaconObserver.h"
#import "DBDiscountAdvertView.h"
#import "DBPositionViewController.h"
#import "DBNewOrderItemAdditionView.h"
#import "DBAddressViewController.h"

#import <Parse/Parse.h>
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import <BlocksKit/UIControl+BlocksKit.h>

NSString *const kDBDefaultsFaves = @"kDBDefaultsFaves";

#define TAG_OVERLAY 333

@interface DBNewOrderViewController () <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIGestureRecognizerDelegate, DBVenuesTableViewControllerDelegate, DBCardsViewControllerDelegate, DBCommentViewControllerDelegate, DBOrderItemCellDelegate, DBTimePickerViewDelegate, DBNewOrderNDAViewDelegate, DBNewOrderBonusesViewDelegate, DBNewOrderItemAdditionViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *advertView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintAdvertViewHeight;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;

@property (weak, nonatomic) IBOutlet DBNewOrderBonusesView *bonusView;
@property (weak, nonatomic) IBOutlet DBNewOrderTotalView *totalView;
@property (weak, nonatomic) IBOutlet DBNewOrderItemAdditionView *itemAdditionView;

@property (weak, nonatomic) IBOutlet DBNewOrderAdditionalInfoView *additionalInfoView;

@property (weak, nonatomic) IBOutlet DBNewOrderViewHeader *orderHeader;
@property (weak, nonatomic) IBOutlet DBNewOrderViewFooter *orderFooter;

@property (weak, nonatomic) IBOutlet DBNewOrderNDAView *ndaView;

@property (weak, nonatomic) IBOutlet UIButton *continueButton;

@property (strong, nonatomic) DBPositionsViewController *positionsViewController;

@property (strong, nonatomic) OrderManager *orderManager;

@property (nonatomic, strong) NSDictionary *currentCard;

@property (nonatomic, strong) DBTimePickerView *pickerView;

@property (nonatomic, strong) UIView *freeBeverageTipView;

@property (nonatomic, strong) NSMutableArray *itemCells;

@end

@implementation DBNewOrderViewController

- (instancetype)init {
    self = [super init];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.topItem.title = @"";
    self.view.backgroundColor = [UIColor db_backgroundColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeTop;
    self.title = NSLocalizedString(@"Заказ", nil);
    
// ========= Configure Logic =========
    self.orderManager = [OrderManager sharedManager];
    self.delegate = [DBTabBarController sharedInstance];
    self.currentCard = [NSDictionary new];
    
    if (self.repeatedOrder) {
        [[OrderManager sharedManager] purgePositions];
        [[OrderManager sharedManager] overridePositions:self.repeatedOrder.items];
        [OrderManager sharedManager].paymentType = self.repeatedOrder.paymentType;
        [OrderManager sharedManager].venue = self.repeatedOrder.venue;
        
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kDBRepeateOrderNotification object:nil]];
        
        // Hides bar if order repeated
        self.tabBarController.tabBar.hidden = YES;
    } else {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings.png"]
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(clickSettings:)];
    }
// ========= Configure Logic =========
    
    
    
// ========= Configure DBDiscountAdvertView =========
//    self.automaticallyAdjustsScrollViewInsets = NO;
//    double topY = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height + 3;
//    self.constraintAdvertViewTopSpace.constant = topY;
    
//    [self.view layoutIfNeeded];
    
//    DBDiscountAdvertView *discountAdView = [DBDiscountAdvertView new];
//    [discountAdView.advertImageView templateImageWithName:@"percent_icon"];
//    self.advertView.hidden = NO;
//    [self.advertView addSubview:discountAdView];
    self.constraintAdvertViewHeight.constant = 0;
// ========= Configure DBDiscountAdvertView =========
    
    
    
// ========= Configure TableView =========
    self.tableView.backgroundColor = [UIColor db_backgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.itemCells = [NSMutableArray new];
    
//    UINib *nib =[UINib nibWithNibName:@"DBOrderItemCell" bundle:[NSBundle mainBundle]];
//    [self.tableView registerNib:nib forCellReuseIdentifier:@"DBOrderItemCell"];
//    
//    nib =[UINib nibWithNibName:@"DBOrderItemNotesCell" bundle:[NSBundle mainBundle]];
// ========= Configure TableView =========
    
    
 
// ========= Configure Time =========
    self.pickerView = [[DBTimePickerView alloc] initWithDelegate:self];
    [_orderManager addObserver:self
                    forKeyPath:@"selectedTime"
                       options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                       context:nil];
// ========= Configure Time =========

    
// ========= Configure Autolayout =========
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView alignLeading:@"0" trailing:@"0" toView:self.view];
// ========= Configure Autolayout =========r
    
    self.itemAdditionView.delegate = self;
    self.itemAdditionView.showBonusPositionsView = NO;
    
    [self.additionalInfoView hide:nil completion:^{
        [self.scrollView layoutIfNeeded];
    }];
    [self setupFooterView];
    [self setupContinueButton];
    
    self.bonusView.delegate = self;
    self.ndaView.delegate = self;
    [self startUpdatingPromoInfo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_orderManager reloadTotal];
    
    [self reloadItemAdditionView];
    [self reloadVenue];
    [self reloadTime];
    [self reloadCard];
    [self reloadProfile];
    [self reloadContinueButton];
    [self reloadComment];
    [self reloadBonusesView:NO];
    [self reloadNDAView];
    
    [self.itemCells removeAllObjects];
    
    [self.tableView reloadData];
    [self reloadTableViewHeight:NO];
    
    [[IHPaymentManager sharedInstance] synchronizePaymentTypes];
    
    if (![OrderManager sharedManager].orderId) {
        [[OrderManager sharedManager] registerNewOrderWithCompletionHandler:nil];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        if(self == self.navigationController.visibleViewController){
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if (![defaults boolForKey:@"ibeacon_question"]) {
                
                [defaults setBool:YES forKey:@"ibeacon_question"];
                [defaults synchronize];
                
                [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Спец. предложения", nil)
                                               message:NSLocalizedString(@"Хотите ли вы активировать контекстные уведомления, чтобы мы присылалали вам спец. предложения и полезную информацию в зависимости от вашего местоположения?", nil)
                                     cancelButtonTitle:NSLocalizedString(@"Нет, спасибо", nil)
                                     otherButtonTitles:@[NSLocalizedString(@"Да, пожалуйста", nil)]
                                               handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                   if (buttonIndex == 1) {
                                                       [defaults setBool:YES forKey:kDBSettingsNotificationsEnabled];
                                                       [defaults synchronize];
                                                       
                                                       [DBBeaconObserver createBeaconObserver];
                                                   } else {
                                                   }
                                               }];
            } else {
                if ([defaults boolForKey:kDBSettingsNotificationsEnabled]) {
                    [DBBeaconObserver createBeaconObserver];
                }
            }
        }
    });
    
    [[DBMastercardPromo sharedInstance] synchronisePromoInfoForClient:[IHSecureStore sharedInstance].clientId];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [GANHelper analyzeScreen:ORDER_SCREEN];
  
    if([OrderManager sharedManager].positionsCount > 0){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self showHintForUser];
        });
    }

    if ([OrderManager sharedManager].totalCount == 0) {
        [self endUpdatingPromoInfo];
    }
}

- (void)dealloc{
    NSLog(@"dealloc");
    
    [_orderManager removeObserver:self forKeyPath:@"selectedTime"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context{
    if([keyPath isEqualToString:@"selectedTime"]){
        [self reloadTime];
    }
}


- (void)setupFooterView {
    // Configure all buttons and some other elements
    [self.orderFooter.venueButton addTarget:self action:@selector(clickAddress:) forControlEvents:UIControlEventTouchUpInside];
    [self.orderFooter.readyTimeButton addTarget:self action:@selector(clickTime:) forControlEvents:UIControlEventTouchUpInside];
    [self.orderFooter.profileButton addTarget:self action:@selector(clickProfile:) forControlEvents:UIControlEventTouchUpInside];
    [self.orderFooter.paymentButton addTarget:self action:@selector(clickPaymentType:) forControlEvents:UIControlEventTouchUpInside];
    [self.orderFooter.commentButton addTarget:self action:@selector(clickComment:) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - Events

- (void)clickSettings:(id)sender {
    DBSettingsTableViewController *settingsController = [DBClassLoader loadSettingsViewController];
    settingsController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:settingsController animated:YES];
}


#pragma mark - Some methods

- (void)showHintForUser{
    int numberOfHintsUsed = [[[NSUserDefaults standardUserDefaults] objectForKey:@"NumberOfPositionCellHintForUser"] intValue];
    
    if(numberOfHintsUsed < 3){
        NSUInteger count = [[OrderManager sharedManager] positionsCount];
        DBOrderItemCell *cell = (DBOrderItemCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:count - 1 inSection:0]];
        
        [cell moveContentToLeft:YES];
        
        numberOfHintsUsed ++;
        [[NSUserDefaults standardUserDefaults] setObject:@(numberOfHintsUsed)
                                                  forKey:@"NumberOfPositionCellHintForUser"];
    }
}


#pragma mark - helper methods

- (NSString *)addressWithoutCity:(NSString *)address{
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"," options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:address options:0 range:NSMakeRange(0, address.length)];
    
    NSString *result = address;
    if([matches count] > 0){
         NSTextCheckingResult *match = matches[0];
        result = [address stringByReplacingCharactersInRange:NSMakeRange(0, match.range.location + match.range.length)
                                                  withString:@""];
        while ([result hasPrefix:@" "]){
            result = [result stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
        }
    }
    
    return result;
}

#pragma mark - Promo

- (void)startUpdatingPromoInfo{
    BOOL startUpdating = [[DBPromoManager sharedManager] checkCurrentOrder:^(BOOL success) {
        [self endUpdatingPromoInfo];
        
        if(success){
            // Show order promos & errors
            NSArray *promos = [DBPromoManager sharedManager].promos;
            NSArray *errors = [DBPromoManager sharedManager].errors;
            
            [self showOrHideAdditionalInfoViewWithErrors:errors promos:promos];
            
            BOOL shouldReloadAgain = NO;
            for(int i = 0; i < [OrderManager sharedManager].items.count; i++){
                OrderItem *item = [[OrderManager sharedManager] itemAtIndex:i];
                DBPromoItem *promoItem = [[DBPromoManager sharedManager] promosForOrderItem:item];
                
                DBOrderItemCell *cell = (DBOrderItemCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                cell.promoItem = promoItem;
                
                if(promoItem.substitute && promoItem.replaceToSubstituteAutomatic){
                    [_orderManager replaceOrderItem:cell.orderItem withPosition:promoItem.substitute];
                    [promoItem clear];
                    shouldReloadAgain = YES;
                }
            }

            if(shouldReloadAgain){
                [self startUpdatingPromoInfo];
            }
            [self reloadVisibleCells];
            
            // Gifts logic
            [self.itemAdditionView showBonusPositionsView:[DBPromoManager sharedManager].bonusPositionsAvailable animated:YES];

        } else {
            [self.additionalInfoView showErrors:@[NSLocalizedString(@"Не удалось обновить сумму заказа, пожалуйста проверьте ваше интернет-соединение", nil)]
                                      animation:^{
                                          [self.scrollView layoutIfNeeded];
                                      } completion:nil];
        }
        
        [self reloadBonusesView:YES];
    }];
    
    if(startUpdating){
        [self.totalView startUpdating];
        [self reloadContinueButton];
    }
}

- (void)endUpdatingPromoInfo{
    [self.totalView endUpdating];
    
    [self reloadContinueButton];
}

- (void) showOrHideAdditionalInfoViewWithErrors:(NSArray *)errors promos:(NSArray *)promos {
    if ((!errors || [errors count] == 0) && (!promos || [promos count] == 0)) {
        [self.additionalInfoView hide:^{
            [self.scrollView layoutIfNeeded];
        } completion:nil];
    } else {
        if ([errors count] != 0) {
            [self.additionalInfoView showErrors:errors animation:^{
                [self.scrollView layoutIfNeeded];
            } completion:nil];
        } else {
            [self.additionalInfoView showPromos:promos animation:^{
                [self.scrollView layoutIfNeeded];
            } completion:nil];
        }
    }
}


#pragma mark - Personal wallet

- (void)reloadBonusesView:(BOOL)animated{
    if([DBPromoManager sharedManager].walletPointsAvailableForOrder > 0){
        self.bonusView.bonusSwitchActive = [DBPromoManager sharedManager].walletActiveForOrder;
        [self.bonusView show:animated completion:^{
            [self.scrollView layoutIfNeeded];
        }];
    } else {
        [self.bonusView hide:animated completion:^{
            [self.scrollView layoutIfNeeded];
        }];
    }
}

- (void)db_newOrderBonusesView:(DBNewOrderBonusesView *)view didSelectBonuses:(BOOL)select{
    [DBPromoManager sharedManager].walletActiveForOrder = select;
    [self reloadBonusesView:NO];
}


#pragma mark - Order Items

- (void)reloadTableViewHeight:(BOOL)animated{
    int height = 0;
    
    NSArray *items = [[OrderManager sharedManager].items arrayByAddingObjectsFromArray:[OrderManager sharedManager].bonusPositions];
    for(OrderItem *item in items)
        if(item.position.hasImage){
            height += 100;
        } else {
            height += 60;
        }
    
    if(animated){
        [UIView animateWithDuration:0.3 animations:^{
            self.tableViewHeightConstraint.constant = height;
            [self.tableView layoutIfNeeded];
            [self.scrollView layoutIfNeeded];
        }];
    } else {
        self.tableViewHeightConstraint.constant = height;
        [self.tableView layoutIfNeeded];
        [self.scrollView layoutIfNeeded];
    }
}

- (void)reloadVisibleCells{
    NSArray *cells = [self.tableView visibleCells];
    for(DBOrderItemCell *cell in cells){
        [cell reload];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return [[OrderManager sharedManager] positionsCount];
    } else {
        return [[OrderManager sharedManager] bonusPositionsCount];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBOrderItemCell *cell;
    
    OrderItem *item;
    if(indexPath.section == 0){
        item = [[OrderManager sharedManager] itemAtIndex:indexPath.row];
    } else {
        item = [OrderManager sharedManager].bonusPositions[indexPath.row];
    }
    
    if(item.position.hasImage){
        cell = [tableView dequeueReusableCellWithIdentifier:@"DBOrderItemCell"];
        
        if (!cell) {
            cell = [[DBOrderItemCell alloc] initWithType:DBOrderItemCellTypeFull];
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"DBOrderItemCompactCell"];
        
        if (!cell) {
            cell = [[DBOrderItemCell alloc] initWithType:DBOrderItemCellTypeCompact];
        }
    }
    
    cell.delegate = self;
    cell.panGestureRecognizer.delegate = self;
    
    cell.orderItem = item;
    
    if(indexPath.section == 0){
        DBPromoItem *promoItem = [[DBPromoManager sharedManager] promosForOrderItem:item];
        cell.promoItem = promoItem;
    }
    
    [cell configure];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    OrderItem *item;
    
    if(indexPath.section == 0){
        item = [[OrderManager sharedManager] itemAtIndex:indexPath.row];
    } else {
        item = [OrderManager sharedManager].bonusPositions[indexPath.row];
    }
    
    if(item.position.hasImage){
        return 100;
    } else {
        return 60;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 1;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section == 1) ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [[OrderManager sharedManager] removeBonusPositionAtIndex:indexPath.row];
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationLeft];
    [self reloadTableViewHeight:YES];
    [self.tableView endUpdates];
    
    [self startUpdatingPromoInfo];
}

#pragma mark - DBOrderItemCellDelegate

- (BOOL)db_orderItemCellCanEdit:(DBOrderItemCell *)cell{
    return ![cell.orderItem.position isKindOfClass:[DBMenuBonusPosition class]];
}

- (void)removeRowAtIndex:(NSInteger)index{
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                           withRowAnimation:UITableViewRowAnimationLeft];
    [self reloadTableViewHeight:YES];
    [self.tableView endUpdates];
    
    if ([OrderManager sharedManager].totalCount == 0) {
        [[DBPromoManager sharedManager] clear];
        [self reloadBonusesView:YES];
        [self.additionalInfoView hide:^{
            [self.scrollView layoutIfNeeded];
        } completion:nil];
    }
}

- (void)db_orderItemCellIncreaseItemCount:(DBOrderItemCell *)cell{
    NSInteger index = [self.tableView indexPathForCell:cell].row;
    [[OrderManager sharedManager] increaseOrderItemCountAtIndex:index];
    
    [cell reloadCount];
    [self startUpdatingPromoInfo];
    [self reloadCard];
    [self reloadContinueButton];
}

- (void)db_orderItemCellDecreaseItemCount:(DBOrderItemCell *)cell{
    NSInteger index = [self.tableView indexPathForCell:cell].row;
    NSInteger count = [[OrderManager sharedManager] decreaseOrderItemCountAtIndex:index];
    
    if(count == 0){
        [self removeRowAtIndex:index];
    } else {
        [cell reloadCount];
    }
    
    [self startUpdatingPromoInfo];
    [self reloadContinueButton];
    [self reloadCard];
}

- (void)db_orderItemCellSwipe:(DBOrderItemCell *)cell{
}

- (void)db_orderItemCellDidSelect:(DBOrderItemCell *)cell{
    OrderItem *item = cell.orderItem;
    if(![item.position isKindOfClass:[DBMenuBonusPosition class]]){
        DBPositionViewController *positionVC = [[DBPositionViewController alloc] initWithPosition:item.position mode:DBPositionViewControllerModeOrderPosition];
        positionVC.parentNavigationController = self.navigationController;
        positionVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:positionVC animated:YES];
    }
}

- (void)db_orderItemCellDidSelectDelete:(DBOrderItemCell *)cell{
    NSInteger index = [self.tableView indexPathForCell:cell].row;
    [_orderManager removeOrderItemAtIndex:index];
    [self removeRowAtIndex:index];
    
    [self startUpdatingPromoInfo];
}

- (void)db_orderItemCellDidSelectReplace:(DBOrderItemCell *)cell{
    if(cell.promoItem.substitute){
        NSInteger index = [_orderManager replaceOrderItem:cell.orderItem withPosition:cell.promoItem.substitute];
        [cell.promoItem clear];
        
        if(index != -1){
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }
        [cell reload];
        [self reloadTableViewHeight:YES];
    }
    
    [self startUpdatingPromoInfo];
}


#pragma mark - DBNewOrderItemAdditionView

- (void)reloadItemAdditionView{
    [self.itemAdditionView reload];
}

- (void)db_newOrderItemAdditionViewDidSelectPositions:(DBNewOrderItemAdditionView *)view{
    if(!self.positionsViewController){
        self.positionsViewController = [DBPositionsViewController new];
        self.positionsViewController.hidesBottomBarWhenPushed = YES;
    }
    
    [GANHelper analyzeEvent:@"plus_click" category:ORDER_SCREEN];
    
    [self.navigationController pushViewController:self.positionsViewController animated:YES];
}

- (void)db_newOrderItemAdditionViewDidSelectBonusPositions:(DBNewOrderItemAdditionView *)view{
    DBBonusPositionsViewController *bonusPositionsVC = [DBBonusPositionsViewController new];
    bonusPositionsVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:bonusPositionsVC animated:YES];
}


#pragma mark - Delivery/Venue

- (void)reloadVenue{
    if (_orderManager.venue) {
        [self setVenue:_orderManager.venue];
    } else {
        [self.orderFooter.activityIndicator startAnimating];
        [[LocationHelper sharedInstance] updateLocationWithCallback:^(CLLocation *location) {
            [OrderManager sharedManager].location = location;
            
            if (location) {
                [Venue fetchVenuesForLocation:location withCompletionHandler:^(NSArray *venues) {
                    if(!venues)
                        venues = [Venue storedVenues];
                    
                    [self setVenue:[venues firstObject]];
                }];
            } else {
                [self setVenue:[[Venue storedVenues] firstObject]];
            }
            
            [self.orderFooter.activityIndicator stopAnimating];
            [self reloadContinueButton];
        }];
    }
}

- (void)setVenue:(Venue *)venue{
    if(venue){
        [OrderManager sharedManager].venue = venue;
        
        self.orderFooter.labelAddress.text = venue.title;
        self.orderFooter.labelAddress.textColor = [UIColor blackColor];
        [self.orderFooter.labelAddress db_stopObservingAnimationNotification];
        
        [self startUpdatingPromoInfo];
    } else {
        self.orderFooter.labelAddress.textColor = [UIColor orangeColor];
        self.orderFooter.labelAddress.text = NSLocalizedString(@"Ошибка определения локации", nil);
        [self.orderFooter.labelAddress db_startObservingAnimationNotification];
    }
    
    [self reloadTime];
    
    [self.orderFooter.activityIndicator stopAnimating];
}

- (IBAction)clickAddress:(id)sender {
    [GANHelper analyzeEvent:@"venues_click" category:ORDER_SCREEN];
    
    DBAddressViewController *addressController = [[DBAddressViewController alloc] initWithDelegate:self];
    addressController.view.frame = [[UIScreen mainScreen] bounds];
    addressController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:addressController animated:YES];
}

- (void)venuesController:(DBVenuesTableViewController *)controller didChooseVenue:(Venue *)venue {
    [self setVenue:venue];
    [self.orderFooter.activityIndicator stopAnimating];
}


#pragma mark - Time

- (void)reloadTime{
    NSString *timeString = [self selectedTimeString];
    if([OrderManager sharedManager].deliveryType.typeId == DeliveryTypeIdShipping){
        timeString = [NSString stringWithFormat:@"%@ | %@", timeString, NSLocalizedString(@"Доставка", nil)];
    }
    if([OrderManager sharedManager].deliveryType.typeId == DeliveryTypeIdTakeaway){
        timeString = [NSString stringWithFormat:@"%@ | %@", timeString, NSLocalizedString(@"Возьму с собой", nil)];
    }
    if([OrderManager sharedManager].deliveryType.typeId == DeliveryTypeIdInRestaurant){
        timeString = [NSString stringWithFormat:@"%@ | %@", timeString, NSLocalizedString(@"На месте", nil)];
    }
    
    self.orderFooter.labelTime.text = timeString;
}

- (void)reloadTimePicker{
    if(_orderManager.deliveryType.useTimePicker){
        self.pickerView.type = _orderManager.deliveryType.onlyTime ? DBTimePickerTypeTime : DBTimePickerTypeDate;
        
        self.pickerView.selectedDate = _orderManager.selectedTime;
    } else {
        self.pickerView.type = DBTimePickerTypeItems;
        
        self.pickerView.items = _orderManager.deliveryType.timeSlotsNames;
        self.pickerView.selectedItem = [_orderManager.deliveryType.timeSlots indexOfObject:_orderManager.selectedTimeSlot];
    }
    
    NSMutableArray *titles = [NSMutableArray new];
    if([[DBCompanyInfo sharedInstance] isDeliveryTypeEnabled:DeliveryTypeIdInRestaurant]){
        [titles addObject:NSLocalizedString(@"С собой", nil)];
    }
    if([[DBCompanyInfo sharedInstance] isDeliveryTypeEnabled:DeliveryTypeIdTakeaway]){
        [titles addObject:NSLocalizedString(@"На месте", nil)];
    }
    self.pickerView.segments = titles;
    self.pickerView.selectedSegmentIndex = _orderManager.deliveryType.typeId == DeliveryTypeIdTakeaway ? 0 : 1;
    
    [self.pickerView configure];
}

- (IBAction)clickTime:(id)sender {
    [GANHelper analyzeEvent:@"time_click" category:ORDER_SCREEN];
    
    [self reloadTimePicker];
    [self.pickerView showOnView:self.tabBarController.view];
}

- (NSString *)selectedTimeString{
    NSString *timeString;
    if(_orderManager.deliveryType.useTimePicker){
        NSDateFormatter *formatter = [NSDateFormatter new];
        if(_orderManager.deliveryType.onlyTime){
            formatter.dateFormat = @"HH:mm";
        } else {
            formatter.dateFormat = @"dd/MM/yy HH:mm";
        }
        timeString = [formatter stringFromDate:_orderManager.selectedTime];
    } else {
        timeString = _orderManager.selectedTimeSlot.slotTitle;
    }
    
    return timeString;
}

- (NSString *)stringFromTime:(NSDate *)date{
    NSDateFormatter *formatter = [NSDateFormatter new];
    if(_orderManager.deliveryType.onlyTime){
        formatter.dateFormat = @"HH:mm";
    } else {
        formatter.dateFormat = @"dd/MM/yy HH:mm";
    }
    
    return [formatter stringFromDate:date];
}

- (void)db_timePickerView:(DBTimePickerView *)view didSelectSegmentAtIndex:(NSInteger)index{
    DeliveryTypeId deliveryTypeId;
    if (index == 0){
        deliveryTypeId = DeliveryTypeIdTakeaway;
    } else {
        deliveryTypeId = DeliveryTypeIdInRestaurant;
    }
    
    _orderManager.deliveryType = [[DBCompanyInfo sharedInstance] deliveryTypeById:deliveryTypeId];
    
    [self reloadTimePicker];
}

- (void)db_timePickerView:(DBTimePickerView *)view didSelectRowAtIndex:(NSInteger)index{
    DBTimeSlot *timeSlot = _orderManager.deliveryType.timeSlots[index];
    _orderManager.selectedTimeSlot = timeSlot;
    [self reloadTime];
}

- (void)db_timePickerView:(DBTimePickerView *)view didSelectDate:(NSDate *)date{
    NSInteger comparisonResult = [_orderManager setNewSelectedTime:date];
    
    NSString *message;
    if(comparisonResult == NSOrderedAscending){
        message = [NSString stringWithFormat:@"Минимальное время для выбора - %@", [self stringFromTime:_orderManager.deliveryType.minDate]];
        [self showAlert:message];
    }
    
    if(comparisonResult == NSOrderedDescending){
        message = [NSString stringWithFormat:@"Максимальное время для выбора - %@", [self stringFromTime:_orderManager.deliveryType.maxDate]];
        [self showAlert:message];
    }
    
//    if(comparisonResult == NSOrderedSame){
//        [self reloadTime];
//    }
}

- (BOOL)db_shouldHideTimePickerView{
    [self reloadTime];
    [self startUpdatingPromoInfo];
    
    return YES;
}


#pragma mark - Profile

- (void)reloadProfile {
    if ([[DBClientInfo sharedInstance] validClientName]) {
        if (![[DBClientInfo sharedInstance] validClientPhone]) {
            self.orderFooter.labelProfile.text = NSLocalizedString(@"Укажите, пожалуйста, номер телефона", nil);
            self.orderFooter.labelProfile.textColor = [UIColor orangeColor];
            [self.orderFooter.labelProfile db_startObservingAnimationNotification];
        } else {
            self.orderFooter.labelProfile.text = [DBClientInfo sharedInstance].clientName;
            self.orderFooter.labelProfile.textColor = [UIColor blackColor];
            [self.orderFooter.labelProfile db_stopObservingAnimationNotification];
        }
    } else {
        self.orderFooter.labelProfile.text = NSLocalizedString(@"Представьтесь, пожалуйста", nil);
        self.orderFooter.labelProfile.textColor = [UIColor orangeColor];
        [self.orderFooter.labelProfile db_startObservingAnimationNotification];
    }
}

- (IBAction)clickProfile:(id)sender {
    [GANHelper analyzeEvent:@"profile_click" category:ORDER_SCREEN];
    NSString *eventLabel;
    if([[DBClientInfo sharedInstance] validClientName] || [[DBClientInfo sharedInstance] validClientPhone]){
        eventLabel = [NSString stringWithFormat:@"%@,%@", [DBClientInfo sharedInstance].clientName, [DBClientInfo sharedInstance].clientPhone];
    } else {
        eventLabel = @"null";
    }
    DBProfileViewController *profileViewController = [DBProfileViewController new];
    profileViewController.screen = @"Profile_order_screen";
    [self.navigationController pushViewController:profileViewController animated:YES];
}


#pragma mark - Payment

- (void)reloadCard {
    [self.orderFooter.labelCard db_stopObservingAnimationNotification];
    
    switch ([OrderManager sharedManager].paymentType) {
        case PaymentTypeNotSet:
            [[OrderManager sharedManager] selectIfPossibleDefaultPaymentType];
            if([OrderManager sharedManager].paymentType != PaymentTypeNotSet){
                [self reloadCard];
            } else {
                self.orderFooter.labelCard.textColor = [UIColor orangeColor];
                self.orderFooter.labelCard.text = NSLocalizedString(@"Выберите тип оплаты", nil);
                [self.orderFooter.labelCard db_startObservingAnimationNotification];
            }
            break;
            
        case PaymentTypeCard:
            self.currentCard = [[IHSecureStore sharedInstance] defaultCard];
            
            if (self.currentCard) {
                NSString *cardNumber = self.currentCard[@"cardPan"];
                NSString *pan = [cardNumber substringFromIndex:cardNumber.length-4];
                self.orderFooter.labelCard.text = [NSString stringWithFormat:@"%@ ....%@", [cardNumber db_cardIssuer], pan];
                self.orderFooter.labelCard.textColor = [UIColor blackColor];
            } else {
                self.orderFooter.labelCard.text = NSLocalizedString(@"Нет карт", nil);
                self.orderFooter.labelCard.textColor = [UIColor orangeColor];
                [self.orderFooter.labelCard db_startObservingAnimationNotification];
            }
            break;
            
        case PaymentTypeCash:
            self.orderFooter.labelCard.textColor = [UIColor blackColor];
            self.orderFooter.labelCard.text = NSLocalizedString(@"Наличные", nil);
            break;
            
        case PaymentTypeExtraType:
            if([OrderManager sharedManager].totalCount > [DBMastercardPromo sharedInstance].promoCurrentMugCount){
                [OrderManager sharedManager].paymentType = PaymentTypeNotSet;
                [self reloadCard];
            } else {
                self.orderFooter.labelCard.textColor = [UIColor blackColor];
                self.orderFooter.labelCard.text = NSLocalizedString(@"Бесплатные кружки", nil);
            }
            break;
            
    }
    
    if([OrderManager sharedManager].totalCount <= [DBMastercardPromo sharedInstance].promoCurrentMugCount && [OrderManager sharedManager].paymentType != PaymentTypeExtraType){
        if(!self.freeBeverageTipView){
            self.freeBeverageTipView = self.orderFooter.freeBeverageTipView;
            self.freeBeverageTipView.userInteractionEnabled = YES;
            [self.freeBeverageTipView addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
                [OrderManager sharedManager].paymentType = PaymentTypeExtraType;
                [self reloadCard];
            }]];
            
            //[self.viewFooter showFreeBeverageTip];
        }
    } else {
        if(self.freeBeverageTipView){
            //[self.viewFooter hideFreeBeverageTip];
            self.freeBeverageTipView = nil;
        }
    }
}

- (IBAction)clickPaymentType:(id)sender {
    NSString *label = @"";
    switch ([OrderManager sharedManager].paymentType) {
        case PaymentTypeNotSet:
            label = @"not_set";
            break;
        case PaymentTypeCash:
            label = @"cash";
            break;
        case PaymentTypeCard:
            label = @"card";
            break;
        case PaymentTypeExtraType:
            label = @"extra_type";
            break;
    }
    
    [GANHelper analyzeEvent:@"payment_click" label:label category:ORDER_SCREEN];
    
    DBCardsViewController *cardsController = [DBCardsViewController new];
    cardsController.mode = CardsViewControllerModeChoosePayment;
    cardsController.delegate = self;
    cardsController.screen = @"Cards_payment_screen";
    [self.navigationController pushViewController:cardsController animated:YES];
}

- (void)cardsControllerDidChoosePaymentItem:(DBCardsViewController *)controller{
    [self startUpdatingPromoInfo];
}


#pragma mark - Comment

- (void)reloadComment {
    if ([OrderManager sharedManager].comment.length > 0) {
        if ([OrderManager sharedManager].comment.length > 10) {
            self.orderFooter.labelComment.text = [NSString stringWithFormat:@"%@...", [[OrderManager sharedManager].comment substringToIndex:10]];
        } else {
            self.orderFooter.labelComment.text = [OrderManager sharedManager].comment;
        }
    } else {
        self.orderFooter.labelComment.text = NSLocalizedString(@"Комментарий", nil);
    }
}

- (IBAction)clickComment:(id)sender {
    [GANHelper analyzeEvent:@"comment_screen" category:ORDER_SCREEN];
    DBCommentViewController *commentController = [DBCommentViewController new];
    commentController.delegate = self;
    commentController.comment = [OrderManager sharedManager].comment;
    [self.navigationController pushViewController:commentController animated:YES];
}

- (void)commentViewController:(DBCommentViewController *)controller didFinishWithText:(NSString *)text {
    [OrderManager sharedManager].comment = text;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - NDA

- (void)reloadNDAView{
    BOOL showNDA = ![[[NSUserDefaults standardUserDefaults] objectForKey:kDBDefaultsNDASigned] boolValue];
    showNDA = showNDA || !([Order allOrders].count > 0);
    if(showNDA){
        [self.ndaView show];
    } else {
        [self.ndaView hide];
    }
}

- (void)db_newOrderNDAViewDidTapNDALabel:(DBNewOrderNDAView *)ndaView{
    DBHTMLViewController *paymentVC = [DBHTMLViewController new];
    paymentVC.title = NSLocalizedString(@"Правила оплаты", nil);
    paymentVC.url = [DBCompanyInfo db_paymentRulesUrl];
    paymentVC.screen = PAYMENT_RULES_SCREEN;
    
    [GANHelper analyzeEvent:@"confidence_show" category:ORDER_SCREEN];
    
    paymentVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:paymentVC animated:YES];
}

- (void)db_newOrderNDAView:(DBNewOrderNDAView *)ndaView didSelectSwitchState:(BOOL)on{
    [self reloadContinueButton];
    if (on) {
        [GANHelper analyzeEvent:@"accept_policy" category:ORDER_SCREEN];
    } else {
        [GANHelper analyzeEvent:@"decline_policy" category:ORDER_SCREEN];
    }
}


#pragma mark - Continue

- (void)setupContinueButton {
    self.continueButton.layer.cornerRadius = 5;
    [self.continueButton addTarget:self action:@selector(clickContinue:) forControlEvents:UIControlEventTouchUpInside];
    [self.continueButton setTitle:NSLocalizedString(@"Заказать", nil) forState:UIControlStateNormal];
    self.continueButton.backgroundColor = [UIColor db_defaultColor];
}

- (void)reloadContinueButton {
    if (![OrderManager sharedManager].validOrder) {
        self.continueButton.backgroundColor = [UIColor db_grayColor];
        self.continueButton.alpha = 0.5;
    } else {
        self.continueButton.backgroundColor = [UIColor db_defaultColor];
        self.continueButton.alpha = 1;
    }
}

- (void)clickContinue:(id)sender {
    if(![OrderManager sharedManager].orderId){
        [[OrderManager sharedManager] registerNewOrderWithCompletionHandler:nil];
        return;
    }
    
    [GANHelper analyzeEvent:@"order_button_click" label:[OrderManager sharedManager].orderId category:ORDER_SCREEN];
    
    if(![OrderManager sharedManager].validOrder){
        [self startUpdatingPromoInfo];
        
        // Nice animation for all error elements
        void (^animationBlock)(UIView*) = ^void(UIView *targetView){
            if([targetView isKindOfClass:[UILabel class]]){
                UILabel *label = (UILabel *)targetView;
                [UIView animateWithDuration:0.2 animations:^{
                    label.alpha = 0;
                    label.textColor = [UIColor redColor];
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.2 animations:^{
                        label.alpha = 1;
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:0.2 animations:^{
                            label.alpha = 0;
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:0.2 animations:^{
                                label.alpha = 1;
                                label.textColor = [UIColor orangeColor];
                            }];
                        }];
                    }];
                }];
            } else {
                [UIView animateWithDuration:0.2 animations:^{
                    targetView.alpha = 0;
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.2 animations:^{
                        targetView.alpha = 1;
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:0.2 animations:^{
                            targetView.alpha = 0;
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:0.2 animations:^{
                                targetView.alpha = 1;
                            }];
                        }];
                    }];
                }];
            }
        };
        
        NSNotification *notification = [NSNotification notificationWithName:kDBNewOrderAnimateAllErrorElementsNotification object:animationBlock];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        
        return;
    }
    
    if([OrderManager sharedManager].paymentType == PaymentTypeCard && !self.currentCard){
        [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Ошибка", nil)
                                       message:NSLocalizedString(@"Пожалуйста, добавьте новую карту или выберите одну из существующих", nil)
                             cancelButtonTitle:NSLocalizedString(@"ОК", nil) otherButtonTitles:nil handler:nil];
    } else {
        [self sendOrder];
    }
}

- (void)sendOrder {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [DBServerAPI createNewOrder:^(Order *order) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [self reloadTableViewHeight:NO];
        [self.additionalInfoView hide:^{
            [self.scrollView layoutIfNeeded];
        } completion:nil];
        [GANHelper analyzeEvent:@"order_placed"
                          label:[NSString stringWithFormat:@"%@, %@", [OrderManager sharedManager].orderId, [IHSecureStore sharedInstance].clientId]
                       category:ORDER_SCREEN];
        
        [self.delegate newOrderViewController:self didFinishOrder:order];
    } failure:^(NSString *errorTitle, NSString *errorMessage) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        [self startUpdatingPromoInfo];
        
        if(!errorTitle) errorTitle = NSLocalizedString(@"Ошибка", nil);
        [UIAlertView bk_showAlertViewWithTitle:errorTitle
                                       message:errorMessage
                             cancelButtonTitle:NSLocalizedString(@"ОК", nil)
                             otherButtonTitles:nil
                                       handler:nil];
        [GANHelper analyzeEvent:@"order_failed" label:errorMessage category:ORDER_SCREEN];
    }];
}


#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController class] == [DBOrdersTableViewController class]) {
        [[OrderManager sharedManager] purgePositions];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

@end
