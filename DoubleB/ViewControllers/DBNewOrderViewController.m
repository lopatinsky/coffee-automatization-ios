//
//  DBNewOrderViewController.m
//  DoubleB
//
//  Created by Balaban Alexander on 31/07/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBNewOrderViewController.h"
#import "DBNewOrderTotalView.h"
#import "DBNewOrderViewHeader.h"
#import "DBNewOrderAdditionalInfoView.h"
#import "DBNewOrderNDAView.h"
#import "DBNewOrderViewFooter.h"
#import "IHSecureStore.h"
#import "DBAPIClient.h"
#import "MBProgressHUD.h"
#import "OrderManager.h"
#import "Order.h"
#import "DBMenuPosition.h"
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
#import "DBBeaconObserver.h"
#import "DBDiscountAdvertView.h"
#import "UIImageView+Extension.h"
#import "UIView+FLKAutoLayout.h"

#import <Parse/Parse.h>
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import <BlocksKit/UIGestureRecognizer+BlocksKit.h>
#import <BlocksKit/UIControl+BlocksKit.h>

NSString *const kDBDefaultsFaves = @"kDBDefaultsFaves";

#define TAG_OVERLAY 333

@interface DBNewOrderViewController () <UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, DBVenuesTableViewControllerDelegate, DBCardsViewControllerDelegate, DBCommentViewControllerDelegate, DBPOrderItemTableCellDelegate, DBPromoManagerUpdateInfoDelegate, DBTimePickerViewDelegate, DBNewOrderNDAViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *advertView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;

@property (weak, nonatomic) IBOutlet DBNewOrderTotalView *totalView;
@property (weak, nonatomic) IBOutlet UIButton *addProductButton;
@property (weak, nonatomic) IBOutlet UIImageView *addProductImageView;

@property (weak, nonatomic) IBOutlet DBNewOrderAdditionalInfoView *additionalInfoView;

@property (weak, nonatomic) IBOutlet DBNewOrderViewHeader *orderHeader;
@property (weak, nonatomic) IBOutlet DBNewOrderViewFooter *orderFooter;

@property (weak, nonatomic) IBOutlet DBNewOrderNDAView *ndaView;

@property (weak, nonatomic) IBOutlet UIButton *continueButton;

@property (nonatomic, strong) NSArray *venues;
@property (nonatomic, strong) NSDictionary *currentCard;

@property (nonatomic, strong) NSMutableArray *preferedHeightsForTableView;

@property (nonatomic, strong) DBTimePickerView *pickerHolder;
@property (nonatomic, strong) NSArray *timeOptions;
@property (nonatomic, strong) NSNumber *lastSelectedTime;

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
    self.view.backgroundColor = [UIColor db_backgroundColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeTop;
    self.title = NSLocalizedString(@"Заказ", nil);
    
    
// ========= Configure Logic =========
    [DBPromoManager sharedManager].updateInfoDelegate = self;
    self.delegate = [DBTabBarController sharedInstance];
    self.currentCard = [NSDictionary new];
    self.pickerHolder = [[DBTimePickerView alloc] initWithDelegate:self];
    self.timeOptions = @[@0, @5, @10, @15, @20, @25, @30];
    if(![OrderManager sharedManager].time){
        [OrderManager sharedManager].time = @10;
    }
    
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
        // Inset for tabBar
        //        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.height, 0);
    }
// ========= Configure Logic =========
    
    
    
// ========= Configure DBDiscountAdvertView =========
//    self.automaticallyAdjustsScrollViewInsets = NO;
//    double topY = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height + 3;
//    self.constraintAdvertViewTopSpace.constant = topY;
    
//    [self.view layoutIfNeeded];
    
    DBDiscountAdvertView *discountAdView = [DBDiscountAdvertView new];
    [discountAdView.advertImageView templateImageWithName:@"percent_icon"];
    self.advertView.hidden = NO;
    [self.advertView addSubview:discountAdView];
// ========= Configure DBDiscountAdvertView =========
    
    
    
// ========= Configure TableView =========
    self.tableView.backgroundColor = [UIColor db_backgroundColor];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.itemCells = [NSMutableArray new];
    self.preferedHeightsForTableView = [[NSMutableArray alloc] init];
    
    UINib *nib =[UINib nibWithNibName:@"DBOrderItemCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"DBOrderItemCell"];
    
    nib =[UINib nibWithNibName:@"DBOrderItemNotesCell" bundle:[NSBundle mainBundle]];
// ========= Configure TableView =========
    
    
 
// ========= Configure TimePickerView =========
    self.pickerHolder.backgroundColor = [UIColor db_backgroundColor];
    self.pickerHolder.pickerView.delegate = self;
    self.pickerHolder.pickerView.dataSource = self;
    
    [self.pickerHolder selectMode:[OrderManager sharedManager].beverageMode];
    
    NSUInteger k = [self.timeOptions indexOfObject:[OrderManager sharedManager].time];
    if (k != NSNotFound) {
        [self.pickerHolder.pickerView selectRow:k inComponent:0 animated:NO];
        [self pickerView:self.pickerHolder.pickerView didSelectRow:k inComponent:0];
    }
// ========= Configure TimePickerView =========

    
// ========= Configure Autolayout =========
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView alignLeading:@"0" trailing:@"0" toView:self.view];
// ========= Configure Autolayout =========r
    
    
    [self.additionalInfoView hide:nil completion:^{
        [self.scrollView layoutIfNeeded];
    }];
    [self setupAddProductButton];
    [self setupFooterView];
    [self setupContinueButton];
    
    self.ndaView.delegate = self;
    [self startUpdatingPromoInfo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateNearestCafe];
    [self reloadTime];
    [self reloadCard];
    [self reloadProfile];
    [self reloadContinueButton];
    [self reloadComment];
    
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
                
                [GANHelper analyzeEvent:@"ibeacon_alert" category:@"Notification"];
                [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Спец. предложения", nil)
                                               message:NSLocalizedString(@"Хотите ли вы активировать контекстные уведомления, чтобы мы присылалали вам спец. предложения и полезную информацию в зависимости от вашего местоположения?", nil)
                                     cancelButtonTitle:NSLocalizedString(@"Нет, спасибо", nil)
                                     otherButtonTitles:@[NSLocalizedString(@"Да, пожалуйста", nil)]
                                               handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                   if (buttonIndex == 1) {
                                                       [GANHelper analyzeEvent:@"ibeacon_alert_yes" category:@"Notification"];
                                                       [defaults setBool:YES forKey:kDBSettingsNotificationsEnabled];
                                                       [defaults synchronize];
                                                       
                                                       [DBBeaconObserver createBeaconObserver];
                                                   } else {
                                                       [GANHelper analyzeEvent:@"ibeacon_alert_no" category:@"Notification"];
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
    
    [GANHelper analyzeScreen:@"Order_screen"];
    
//    CGRect rect = [self.tableView convertRect:self.viewFooter.continueButton.frame fromView:self.viewFooter];
//    int visibleTableHeight = [UIScreen mainScreen].bounds.size.height - self.navigationController.navigationBar.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height;
//    if(rect.origin.y + rect.size.height + 5 > visibleTableHeight){
//        static dispatch_once_t onceToken;
//        dispatch_once(&onceToken, ^{
//                [UIView animateWithDuration:0.3f animations:^{
//                    [self.tableView setContentOffset:CGPointMake(0, rect.origin.y + rect.size.height + 5 - self.tableView.bounds.size.height + self.tabBarController.tabBar.frame.size.height)];
//                }];
//        });
//    }
  
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self showHintForUser];
    });

    if ([OrderManager sharedManager].totalCount == 0) {
        [self endUpdatingPromoInfo];
    }
}

- (void)dealloc{
    NSLog(@"dealloc");
}

#pragma mark - Setup

- (void)clickSettings:(id)sender {
    [GANHelper analyzeEvent:@"settings_click" category:@"Menu_screen"];
    
    DBSettingsTableViewController *settingsController = [DBSettingsTableViewController new];
    settingsController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:settingsController animated:YES];
}

- (void)setupFooterView {
    // Configure all buttons and some other elements
    [self.orderFooter.venueButton addTarget:self action:@selector(clickAddress:) forControlEvents:UIControlEventTouchUpInside];
    [self.orderFooter.readyTimeButton addTarget:self action:@selector(clickTime:) forControlEvents:UIControlEventTouchUpInside];
    [self.orderFooter.profileButton addTarget:self action:@selector(clickProfile:) forControlEvents:UIControlEventTouchUpInside];
    [self.orderFooter.paymentButton addTarget:self action:@selector(clickPaymentType:) forControlEvents:UIControlEventTouchUpInside];
    [self.orderFooter.commentButton addTarget:self action:@selector(clickComment:) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *orders = [Order allOrders];
    if([[NSUserDefaults standardUserDefaults] boolForKey:kDBDefaultsNDASigned] && [orders count] > 0){
        [self.ndaView hide];
    }
}

- (void)setupContinueButton {
    self.continueButton.layer.cornerRadius = 5;
    [self.continueButton addTarget:self action:@selector(clickContinue:) forControlEvents:UIControlEventTouchUpInside];
    [self.continueButton setTitle:NSLocalizedString(@"Заказать", nil) forState:UIControlStateNormal];
    self.continueButton.backgroundColor = [UIColor db_defaultColor];
}

#pragma mark - reload content

- (void)reloadTableViewHeight:(BOOL)animated{
    int height = 0;
    for(NSNumber *cellHeight in self.preferedHeightsForTableView)
        height += [cellHeight intValue];
    
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

- (void)reloadTableViewCellsHeight{
    [self.tableView beginUpdates];
    [self reloadTableViewHeight:YES];
    [self.tableView endUpdates];
}

- (void)setupAddProductButton{
    [self.addProductImageView templateImageWithName:@"plus"];
    [self.addProductButton addTarget:self action:@selector(clickAddProductButton) forControlEvents:UIControlEventTouchUpInside];
}

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

- (void)reloadTime{
    NSString *timeString;
    if ([[OrderManager sharedManager].time intValue] > 0) {
        timeString = [NSString stringWithFormat:NSLocalizedString(@"Через %@ минут", nil), [OrderManager sharedManager].time];
    } else {
        timeString = NSLocalizedString(@"Сейчас", nil);
    }
    
    if(![[OrderManager sharedManager].venue.hasTablesInside boolValue]){
        [OrderManager sharedManager].beverageMode = DBBeverageModeTakeaway;
        [self.pickerHolder selectMode:DBBeverageModeTakeaway];
        self.pickerHolder.typeSegmentedControl.enabled = NO;
    } else {
        self.pickerHolder.typeSegmentedControl.enabled = YES;
    }
    
    if([OrderManager sharedManager].beverageMode == DBBeverageModeTakeaway){
        timeString = [NSString stringWithFormat:@"%@ | %@", timeString, NSLocalizedString(@"Возьму с собой", nil)];
    } else {
        timeString = [NSString stringWithFormat:@"%@ | %@", timeString, NSLocalizedString(@"Буду пить в кафе", nil)];
    }
    
    self.orderFooter.labelTime.text = timeString;
}

- (void)reloadProfile {
    if ([[DBClientInfo sharedInstance] validName]) {
        if (![[DBClientInfo sharedInstance] validPhone]) {
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
            
        case PaymentTypePersonalAccount:
            if ([OrderManager sharedManager].totalPrice > [DBMastercardPromo sharedInstance].walletBalance) {
                [OrderManager sharedManager].paymentType = PaymentTypeNotSet;
                [self reloadCard];
            } else {
                self.orderFooter.labelCard.textColor = [UIColor blackColor];
                self.orderFooter.labelCard.text = NSLocalizedString(@"Личный счет", nil);
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

- (void)reloadContinueButton {
    if (![OrderManager sharedManager].validOrder) {
        self.continueButton.backgroundColor = [UIColor db_grayColor];
        self.continueButton.alpha = 0.5;
    } else {
        self.continueButton.backgroundColor = [UIColor db_defaultColor];
        self.continueButton.alpha = 1;
    }
}

- (void)reloadFavourites:(NSArray *)items {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *faves = [defaults objectForKey:kDBDefaultsFaves];

    if(!faves)
        faves = [[NSMutableArray alloc] init];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(NSDictionary *fave in faves){
        [array addObject:[[NSMutableDictionary alloc] initWithDictionary:fave]];
    }
    
    for (NSDictionary *item in items) {
        BOOL found = NO;
        for (NSMutableDictionary *a in array) {
            if ([a[@"id"] isEqualToString:item[@"item_id"]]) {
                a[@"count"] = @([a[@"count"] intValue] + 1);
                found = YES;
                break;
            }
        }
        if (!found) {
            [array addObject:[[NSMutableDictionary alloc] initWithDictionary:@{@"id": item[@"item_id"],
                                                                              @"count": @(1)}]];
        }
    }
    
    [array sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        return [obj1[@"count"] intValue] > [obj2[@"count"] intValue] ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    faves = [[NSMutableArray alloc] init];
    for(NSDictionary *a in array){
        [faves addObject:a];
    }
    
    [defaults setObject:faves forKey:kDBDefaultsFaves];
    [defaults synchronize];
}


- (void)setNearestVenue:(Venue *)nearestVenue{
    if(nearestVenue){
        [OrderManager sharedManager].venue = nearestVenue;
        
        //self.viewFooter.labelAddress.text = [self addressWithoutCity:nearestVenue.address];
        self.orderFooter.labelAddress.text = nearestVenue.title;
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

- (void)updateNearestCafe {
    if ([OrderManager sharedManager].venue) {
        [self setNearestVenue:[OrderManager sharedManager].venue];
    } else {
        [self.orderFooter.activityIndicator startAnimating];
        NSDate *start = [NSDate date];
        [[LocationHelper sharedInstance] updateLocationWithCallback:^(CLLocation *location) {
            [OrderManager sharedManager].location = location;
            
            if (location) {
                [GANHelper analyzeEvent:@"location_found" category:@"Order_screen"];
                
                [Venue fetchVenuesForLocation:location withCompletionHandler:^(NSArray *venues) {

                    long interval = (long)-[start timeIntervalSinceNow];
                    [GANHelper analyzeEvent:@"location_loading_time" label:[NSString stringWithFormat:@"%ld", interval] category:@"Order_screen"];

                    if(![OrderManager sharedManager].venue){
                        if (venues) {
                            [self setNearestVenue:venues[0]];
                            self.venues = venues;
                        } else {
                            venues = [Venue storedVenues];
                            if(venues && [venues count] > 0)
                                [self setNearestVenue:venues[0]];
                            else
                                [self setNearestVenue:nil];
                        }
                    }
                    
                    [self.orderFooter.activityIndicator stopAnimating];
                    [self reloadContinueButton];
                }];
            } else {
                NSString *lastVenueId = [[NSUserDefaults standardUserDefaults] stringForKey:kDBDefaultsLastSelectedVenue];
                Venue *venue = [Venue venueById:lastVenueId];
                
                if(venue){
                    [self setNearestVenue:venue];
                } else {
                    [self setNearestVenue:self.venues[1]];
                }
                [GANHelper analyzeEvent:@"location_not_found" category:@"Order_screen"];
                [self.orderFooter.activityIndicator stopAnimating];
            }
        }];
    }
}

- (void)newTimeWasSelected{
    [self startUpdatingPromoInfo];
}

#pragma mark - Events

- (void)clickRefill:(id)sender {
    [GANHelper analyzeEvent:@"back_add_click" category:@"Order_screen"];

    [self moveBack];
}

- (void)clickAddProductButton{
    DBPositionsViewController *positionsController = [DBPositionsViewController new];
    positionsController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:positionsController animated:YES];
}

- (void)clickContinue:(id)sender {
    if(![OrderManager sharedManager].orderId){
        [[OrderManager sharedManager] registerNewOrderWithCompletionHandler:nil];
        return;
    }
    
    if(![OrderManager sharedManager].validOrder){
        [self startUpdatingPromoInfo];
        
        [GANHelper analyzeEvent:@"order_submit_disable"
                          label:[OrderManager sharedManager].orderId
                       category:@"Order_screen"];
        
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
    
    if ([OrderManager sharedManager].positionsCount == 0) {
        [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Ошибка", nil)
                                       message:NSLocalizedString(@"Для регистрации заказа вам необходимо выбрать хотя бы один напиток", nil)
                             cancelButtonTitle:NSLocalizedString(@"ОК", nil) otherButtonTitles:nil handler:nil];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        return;
    }

    [GANHelper analyzeEvent:@"order_submit" label:[OrderManager sharedManager].orderId category:@"Order_screen"];
    
    switch ([OrderManager sharedManager].paymentType) {
        case PaymentTypeCard:
            if (!self.currentCard) {
                [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Ошибка", nil)
                                               message:NSLocalizedString(@"Пожалуйста, добавьте новую карту или выберите одну из существующих", nil)
                                     cancelButtonTitle:NSLocalizedString(@"ОК", nil) otherButtonTitles:nil handler:nil];
            } else {
                [self sendOrderWithCard:self.currentCard];
            }
            break;
            
        case PaymentTypePersonalAccount:
            [self sendOrderWithCard:nil];
            break;
            
        case PaymentTypeCash:
            [self sendOrderWithCard:nil];
            break;
            
        case PaymentTypeExtraType:
            [self sendOrderWithCard:nil];
            break;
            
        default:
            break;
    }
}

- (IBAction)clickAddress:(id)sender {
    [GANHelper analyzeEvent:@"location_text_click" category:@"Order_screen"];

    DBVenuesTableViewController *venuesController = [DBVenuesTableViewController new];
    venuesController.delegate = self;
    venuesController.venues = self.venues;
    venuesController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:venuesController animated:YES];
}

- (IBAction)clickTime:(id)sender {
    [GANHelper analyzeEvent:@"delivery_time_text" category:@"Order_screen"];

    [self showPicker];
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
        case PaymentTypePersonalAccount:
            label = @"personal_account";
            break;
    }

    [GANHelper analyzeEvent:@"payment_click"
                      label:label
                   category:@"Order_screen"];

    DBCardsViewController *cardsController = [DBCardsViewController new];
    cardsController.mode = CardsViewControllerModeChoosePayment;
    cardsController.delegate = self;
    cardsController.screen = @"Cards_payment_screen";
    [self.navigationController pushViewController:cardsController animated:YES];
}

- (IBAction)clickComment:(id)sender {
    [GANHelper analyzeEvent:@"comment_click" category:@"Order_screen"];

    DBCommentViewController *commentController = [DBCommentViewController new];
    commentController.delegate = self;
    commentController.comment = [OrderManager sharedManager].comment;
    [self.navigationController pushViewController:commentController animated:YES];
}

- (IBAction)clickProfile:(id)sender {
    NSString *eventLabel;
    if([[DBClientInfo sharedInstance] validName] || [[DBClientInfo sharedInstance] validPhone]){
         eventLabel = [NSString stringWithFormat:@"%@,%@", [DBClientInfo sharedInstance].clientName, [DBClientInfo sharedInstance].clientPhone];
    } else {
        eventLabel = @"null";
    }
    [GANHelper analyzeEvent:@"user_profile_click"
                      label:eventLabel
                   category:@"Order_screen"];

    DBProfileViewController *profileViewController = [DBProfileViewController new];
    profileViewController.screen = @"Profile_order_screen";
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (IBAction)clickPickerDone:(id)sender {
    [self hidePicker:nil];
}


#pragma mark - Some methods

- (void)moveBack{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showPicker {
    UIImage *snapshot = [self.tabBarController.view snapshotImage];
    UIImageView *overlay = [[UIImageView alloc] initWithFrame:self.tabBarController.view.bounds];
    overlay.image = [snapshot applyBlurWithRadius:5 tintColor:[UIColor colorWithWhite:0.3 alpha:0.6] saturationDeltaFactor:1.5 maskImage:nil];
    overlay.alpha = 0;
    overlay.tag = TAG_OVERLAY;
    overlay.userInteractionEnabled = YES;
    [overlay addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePicker:)]];
    [self.tabBarController.view addSubview:overlay];
    
    CGRect rect = self.pickerHolder.frame;
    rect.origin.y = self.tabBarController.view.bounds.size.height;
    self.pickerHolder.frame = rect;
    
    [self.tabBarController.view addSubview:self.pickerHolder];
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.pickerHolder.frame;
        frame.origin.y -= self.pickerHolder.bounds.size.height;
        self.pickerHolder.frame = frame;
        
        overlay.alpha = 1;
    }];
    
    self.lastSelectedTime = [OrderManager sharedManager].time;
}

- (void)hidePicker:(id)sender {
    NSString *eventLabel;
    if(sender){
        eventLabel = [NSString stringWithFormat:@"blur;%@;%@", self.lastSelectedTime, [OrderManager sharedManager].time];
    } else {
        eventLabel = [NSString stringWithFormat:@"done;%@;%@", self.lastSelectedTime, [OrderManager sharedManager].time];
    }
    [GANHelper analyzeEvent:@"ready_click " label:eventLabel category:@"Delivery_time_screen"];
    [GANHelper analyzeEvent:@"back_screen_click" category:@"Delivery_time_screen"];
    

    UIView *overlay = [self.tabBarController.view viewWithTag:TAG_OVERLAY];
    
    [UIView animateWithDuration:0.2 animations:^{
        overlay.alpha = 0;
        CGRect rect = self.pickerHolder.frame;
        rect.origin.y = self.tabBarController.view.bounds.size.height;
        self.pickerHolder.frame = rect;
    } completion:^(BOOL f){
        [overlay removeFromSuperview];
        [self.pickerHolder removeFromSuperview];
    }];
    
    [self newTimeWasSelected];
}

- (void)showHintForUser{
    int numberOfHintsUsed = [[[NSUserDefaults standardUserDefaults] objectForKey:@"NumberOfPositionCellHintForUser"] intValue];
    if(numberOfHintsUsed < 3){
        NSUInteger count = [[OrderManager sharedManager] positionsCount];
        DBOrderItemCell *cell = (DBOrderItemCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:count - 1 inSection:0]];
        
        [cell moveContentToLeft];
        
        numberOfHintsUsed ++;
        [[NSUserDefaults standardUserDefaults] setObject:@(numberOfHintsUsed)
                                                  forKey:@"NumberOfPositionCellHintForUser"];
    }
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


#pragma mark - Salt

- (void)sendOrderWithCard:(NSDictionary *)card {
//    NSMutableArray *items = [NSMutableArray new];
//    for (int i = 0; i < [OrderManager sharedManager].positionsCount; ++i) {
//        OrderItem *item = [[OrderManager sharedManager] itemAtIndex:i];
//        Position *position = item.position;
//        
//        NSMutableDictionary *dict = [NSMutableDictionary new];
//        if(item.selectedExt){
//            dict[@"item_id"] = item.selectedExt.extId;
//            dict[@"name"] = [NSString stringWithFormat:@"%@ (%@)", position.title, item.selectedExt.extName];
//        } else {
//            dict[@"item_id"] = position.positionId;
//            dict[@"name"] = position.title;
//        }
//        
//        dict[@"quantity"] = @(item.count);
//        dict[@"price"] = position.price;
//        [items addObject:dict];
//    }
//
//    if (![[OrderManager sharedManager] orderId]) {
//        [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Ошибка", nil)
//                                       message:NSLocalizedString(@"Невозможно разместить заказ. Пожалуйста, проверьте интернет-соединение", nil)
//                             cancelButtonTitle:NSLocalizedString(@"ОК", nil) otherButtonTitles:nil handler:nil];
//        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//        return;
//    }
//    
//    NSMutableDictionary *order = [NSMutableDictionary new];
//    order[@"device_type"] = @(0);
//    order[@"venue_id"] = [OrderManager sharedManager].venue.venueId;
//    order[@"total_sum"] = @([[OrderManager sharedManager] totalPrice]);
//    order[@"items"] = items;
//    order[@"order_id"] = [[OrderManager sharedManager] orderId];
//    order[@"delivery_time"] = [OrderManager sharedManager].time;
//    order[@"takeout"] = @([OrderManager sharedManager].beverageMode == DBBeverageModeTakeaway);
//    
//    NSString *comment = [OrderManager sharedManager].comment ?: @"";
//    if([OrderManager sharedManager].beverageMode == DBBeverageModeTakeaway){
//        comment = [NSString stringWithFormat:@"С собой\n%@", comment];
//    } else {
//        comment = [NSString stringWithFormat:@"Буду пить в кафе\n%@", comment];
//    }
//    order[@"comment"] = comment;
//    
//    static BOOL hasOrderErrorInSession = NO;
//    order[@"after_error"] = @(hasOrderErrorInSession);
//    
//    NSMutableDictionary *client = [NSMutableDictionary new];
//    client[@"id"] = [[IHSecureStore sharedInstance] clientId];
//    client[@"name"] =  [DBClientInfo sharedInstance].clientName;
//    client[@"phone"] = [DBClientInfo sharedInstance].clientPhone;
//    client[@"email"] = [DBClientInfo sharedInstance].clientMail;
//    order[@"client"] = client;
//    
//    NSMutableDictionary *payment = [NSMutableDictionary new];
//    switch ([OrderManager sharedManager].paymentType) {
//        case PaymentTypeCard:{
//            payment[@"type_id"] = @1;
//            if(card[@"cardToken"]){
//                payment[@"binding_id"] = card[@"cardToken"];
//                
//                BOOL mcardOrMaestro = [[card[@"cardPan"] db_cardIssuer] isEqualToString:kDBCardTypeMasterCard] || [[card[@"cardPan"] db_cardIssuer] isEqualToString:kDBCardTypeMaestro];
//                payment[@"mastercard"] = @(mcardOrMaestro);
//                
//                NSString *cardPan = card[@"cardPan"];
//                if(cardPan.length > 4){
//                    cardPan = [cardPan stringByReplacingCharactersInRange:NSMakeRange(0, cardPan.length - 4) withString:@""];
//                }
//                payment[@"card_pan"] = cardPan ?: @"";
//            }
//            payment[@"client_id"] = [[IHSecureStore sharedInstance] clientId];
//            payment[@"return_url"] = @"alpha-payment://return-page";
//        }
//            break;
//            
//        case PaymentTypeCash:
//            payment[@"type_id"] = @0;
//            break;
//            
//        case PaymentTypeExtraType:
//            payment[@"type_id"] = @2;
//            break;
//            
//        case PaymentTypePersonalAccount:
//            payment[@"type_id"] = @3;
//            break;
//            
//        default:
//            break;
//    }
//    order[@"payment"] = payment;
//    
//    if ([OrderManager sharedManager].location) {
//        CLLocation *location = [OrderManager sharedManager].location;
//        order[@"coordinates"] = [NSString stringWithFormat:@"%f,%f", location.coordinate.latitude, location.coordinate.longitude];
//    }
//    
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:order
//                                                       options:NSJSONWritingPrettyPrinted
//                                                         error:nil];
//    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    //NSLog(@"%@", order);
//    NSDate *start = [NSDate date];
//    
//    // Check if network connection is reachable
//    NetworkStatus networkStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
//    if(networkStatus == NotReachable){
//        [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Ошибка", nil)
//                                       message:NSLocalizedString(@"Невозможно разместить заказ. Пожалуйста, проверьте интернет-соединение", nil)
//                             cancelButtonTitle:NSLocalizedString(@"ОК", nil) otherButtonTitles:nil handler:nil];
//        return;
//    }
//    // Check if network connection is reachable
//    
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    [[DBAPIClient sharedClient] POST:@"order.php"
//                          parameters:@{@"order": jsonString}
//                             timeout:30
//                            success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
//                                //NSLog(@"%@", responseObject);
//                                [self reloadFavourites:items];
//                                
//                                [MBProgressHUD hideHUDForView:self.view animated:YES];
//                                
//                                Order *ord = [[Order alloc] init:YES];
//                                ord.orderId = [NSString stringWithFormat:@"%@", responseObject[@"order_id"]];
//                                ord.total = @([[OrderManager sharedManager] totalPrice]);
//                                ord.createdAt = [[NSDate alloc] initWithTimeIntervalSinceNow:[OrderManager sharedManager].time.doubleValue*60];
//                                ord.dataItems = [NSKeyedArchiver archivedDataWithRootObject:[OrderManager sharedManager].positions];
//                                ord.paymentType = [[OrderManager sharedManager] paymentType];
//                                ord.status = OrderStatusNew;
//                                ord.venue = [OrderManager sharedManager].venue;
//                                
//                                [[CoreDataHelper sharedHelper] save];
//                                [self confirmOrderSuccess:ord.orderId];
//                                
//                                [[OrderManager sharedManager] purgePositions];
//                                [self.preferedHeightsForTableView removeAllObjects];
//                                [self reloadTableViewHeight:NO];
//                                [self.additionalInfoView hide:^{
//                                    [self.scrollView layoutIfNeeded];
//                                } completion:nil];
//                                
//                                if(ord.paymentType == PaymentTypeExtraType){
//                                    [[DBMastercardPromo sharedInstance] doneOrderWithMugCount:[OrderManager sharedManager].totalCount];
//                                } else {
//                                    [[DBMastercardPromo sharedInstance] doneOrder];
//                                }
//                                
//                                hasOrderErrorInSession = NO;
//     
//                                [[NSUserDefaults standardUserDefaults] setObject:ord.orderId forKey:@"lastOrderId"];
//                                [[NSUserDefaults standardUserDefaults] synchronize];
//                                
//                                [Compatibility registerForNotifications];
//                                [PFPush subscribeToChannelInBackground:[NSString stringWithFormat:@"order_%@", ord.orderId]];
//                                
//                                [GANHelper trackNewOrderInfo:ord];
//                                
//                                //[GANHelper analyzeEvent:@"order_payment_status" label:@"success" category:@"Order_screen"];
//                                long interval = (long)-[start timeIntervalSinceNow];
//                                [GANHelper analyzeEvent:@"order_payment_time"
//                                                  label:[NSString stringWithFormat:@"%ld", interval]
//                                               category:@"Order_screen"];
//                                [GANHelper analyzeEvent:@"order_submit_success" label:ord.orderId category:@"Order_screen"];
//                                
//                                [self.delegate newOrderViewController:self didFinishOrder:ord];
//                            }
//                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                                NSLog(@"%@", error);
//                                
//                                NSString *eventLabel = [NSString stringWithFormat:@"%@,\n %@", [[OrderManager sharedManager] orderId], error.description];
//                                [GANHelper analyzeEvent:@"order_submit_failure"
//                                                  label:eventLabel
//                                               category:@"Order_screen"];
//                                /*[GANHelper analyzeEvent:@"order_payment_status"
//                                                  label:[NSString stringWithFormat:@"error %@", error.description]
//                                               category:@"Order_screen"];*/
//
//                                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                                
//                                [OrderManager sharedManager].orderId = nil;
//                                [[OrderManager sharedManager] registerNewOrderWithCompletionHandler:nil];
//                                [self startUpdatingPromoInfo];
//
//                                if (error.code == NSURLErrorTimedOut || operation.response.statusCode == 0){
//                                    hasOrderErrorInSession = YES;
//                                    
//                                    [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Ошибка", nil)
//                                                                   message:NSLocalizedString(@"Нестабильное интернет-соединение. Возможно ваш заказ был успешно создан, пожалуйста, дождитесь подтверждения по смс и обновите историю", nil)
//                                                         cancelButtonTitle:NSLocalizedString(@"ОК", nil) otherButtonTitles:nil handler:nil];
//                                }/* else if (operation.response.statusCode == 0) {
//                                    [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Ошибка", nil)
//                                                                   message:NSLocalizedString(@"Невозможно разместить заказ. Пожалуйста, проверьте интернет-соединение", nil)
//                                                         cancelButtonTitle:NSLocalizedString(@"ОК", nil) otherButtonTitles:nil handler:nil];
//                                }*/ else if (operation.response.statusCode == 400) {
//                                    NSString *title = operation.responseObject[@"title"] ?: NSLocalizedString(@"Ошибка", nil);
//                                    [UIAlertView bk_showAlertViewWithTitle:title
//                                                                   message:operation.responseObject[@"description"]
//                                                         cancelButtonTitle:NSLocalizedString(@"ОК", nil) otherButtonTitles:nil handler:nil];
//                                } else {
//                                    [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Ошибка", nil)
//                                                                   message:NSLocalizedString(@"Произошла непредвиденная ошибка при регистрации заказа. Пожалуйста, попробуйте позднее", nil)
//                                                         cancelButtonTitle:NSLocalizedString(@"ОК", nil) otherButtonTitles:nil handler:nil];
//                                }
//                            }];
}

- (void)confirmOrderSuccess:(NSString *)orderId{
    [[DBAPIClient sharedClient] POST:@"set_order_success"
                          parameters:@{@"order_id": orderId}
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                            }
                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 NSLog(@"%@", error);
                             }];
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

#pragma mark - Promo methods

- (void)startUpdatingPromoInfo{
    [self.totalView startUpdating];
    
    [self reloadContinueButton];
    [[DBPromoManager sharedManager] updateInfo];
}

- (void)endUpdatingPromoInfo{
    [self.totalView endUpdating];
    
    [self reloadContinueButton];
}

- (void)applyItemsInfo:(NSArray *)itemsInfo{
    if(!itemsInfo){
        for(int i = 0; i < [OrderManager sharedManager].positionsCount; i++){
            DBOrderItemCell *cell = (DBOrderItemCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [cell.orderItem clearAdditionalInfo];
            [cell itemInfoChanged:YES];
        }
        return;
    }
    
    for(NSDictionary *itemInfo in itemsInfo){
        NSString *itemId = itemInfo[@"id"];
        OrderItem *item = [[OrderManager sharedManager] itemWithPositionId:itemId];
        item.notes = itemInfo[@"promos"];
        item.errors = itemInfo[@"errors"];
        
        NSInteger index = [[OrderManager sharedManager].positions indexOfObject:item];
        DBOrderItemCell *cell = (DBOrderItemCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        [cell itemInfoChanged:YES];
    }
}


#pragma mark - DBPromoManagerDelegate

- (void)promoManager:(DBPromoManager *)manager
       didUpdateInfo:(NSArray *)itemsInfo
          withPromos:(NSArray *)promos{
    [self applyItemsInfo:itemsInfo];
    [self showOrHideAdditionalInfoViewWithErrors:nil promos:promos];
    
    [self endUpdatingPromoInfo];
    [self reloadTableViewCellsHeight];
}

- (void)promoManager:(DBPromoManager *)manager
       didUpdateInfo:(NSArray *)itemsInfo
          withErrors:(NSArray *)errors
          withPromos:(NSArray *)promos{
    [self applyItemsInfo:itemsInfo];
    [self showOrHideAdditionalInfoViewWithErrors:errors promos:promos];
    
    [self endUpdatingPromoInfo];
    [self reloadTableViewCellsHeight];
}

- (void)promoManager:(DBPromoManager *)mamager didFailUpdateInfoWithError:(NSError *)error{
    [self applyItemsInfo:nil];
    [self endUpdatingPromoInfo];
    [self reloadTableViewCellsHeight];
    
    [self.additionalInfoView showErrors:@[NSLocalizedString(@"Не удалось обновить сумму заказа, пожалуйста проверьте ваше интернет-соединение", nil)]
                               animation:^{
                                   [self.scrollView layoutIfNeeded];
                               } completion:nil];
}


#pragma mark - Venues Controller Delegate

- (void)venuesController:(DBVenuesTableViewController *)controller didChooseVenue:(Venue *)venue {
    [self setNearestVenue:venue];
    [self.orderFooter.activityIndicator stopAnimating];
}

#pragma mark - Cards Controller Delegate

- (void)cardsControllerDidChoosePaymentItem:(DBCardsViewController *)controller{
    //[self startUpdatingPromoInfo];
}


#pragma mark - UIPickerViewDataSource

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.timeOptions.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSNumber *option = self.timeOptions[row];
    if (option.integerValue) {
        return [NSString stringWithFormat:NSLocalizedString(@"%@ минут", nil), option];
    } else {
        return NSLocalizedString(@"Сейчас", nil);
    }
}

#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [OrderManager sharedManager].time = self.timeOptions[row];
    [self reloadTime];

    [GANHelper analyzeEvent:@"list_scroll" category:@"Delivery_time_screen"];
}

#pragma mark - DBTimePickerViewDelegate

- (void)db_timePickerView:(DBTimePickerView *)view didChangeMode:(DBBeverageMode)mode{
    [OrderManager sharedManager].beverageMode = mode;
    [self reloadTime];
}

- (void)db_timePickerViewDidChooseTimeOption:(DBTimePickerView *)view{
    [self hidePicker:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[OrderManager sharedManager] positionsCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    
    cell = (DBOrderItemCell *)[tableView dequeueReusableCellWithIdentifier:@"DBOrderItemCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DBOrderItemCell" owner:self options:nil] firstObject];
    }
    
    OrderItem *item = [[OrderManager sharedManager] itemAtIndex:indexPath.row];
    DBMenuPosition *position = item.position;
    NSInteger count = item.count;
    
    ((DBOrderItemCell *)cell).delegate = self;
    ((DBOrderItemCell *)cell).orderItem = item;
    ((DBOrderItemCell *)cell).panGestureRecognizer.delegate = self;
    
    BOOL isTheSame = false;
    for (DBOrderItemCell *oldCell in self.itemCells) {
        if (oldCell == cell) {
            isTheSame = true;
            break;
        }
    }
    if (!isTheSame) {
        [self.itemCells addObject:cell];
    }
    
    UILabel *labelTitle = ((DBOrderItemCell *)cell).itemTitleLabel;
    UILabel *labelCount = ((DBOrderItemCell *)cell).itemQuantityLabel;
    labelCount.textColor = [UIColor db_defaultColor];
    labelTitle.text = position.name;
    
    labelCount.text = [NSString stringWithFormat:@"%ld", (long)count];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row >= [self.preferedHeightsForTableView count]){
        [self.preferedHeightsForTableView addObject:@(55)];
        return 55;
    } else {
        return [self.preferedHeightsForTableView[indexPath.row] floatValue];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [GANHelper analyzeEvent:@"item_title_click" category:@"Order_screen"];
    
    DBOrderItemCell *cell = (DBOrderItemCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell showOrHideAdditionalInfo];
    [self reloadTableViewCellsHeight];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

#pragma mark - DBOrderItemCellDelegate

- (BOOL)orderItemCellCanEdit:(DBOrderItemCell *)cell{
    return YES;
}

- (void)removeRowAtIndex:(NSInteger)index{
    [GANHelper analyzeEvent:@"item_delete" category:@"Order_screen"];
    
    [self.preferedHeightsForTableView removeObjectAtIndex:index];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                           withRowAnimation:UITableViewRowAnimationLeft];
    [self reloadTableViewHeight:YES];
    [self.tableView endUpdates];
    
    if ([OrderManager sharedManager].totalCount == 0) {
        [self.additionalInfoView hide:^{
            [self.scrollView layoutIfNeeded];
        } completion:nil];
    }
}

- (void)orderItemCellIncreaseItemCount:(DBOrderItemCell *)cell{
    NSInteger index = [self.tableView indexPathForCell:cell].row;
    NSInteger count = [[OrderManager sharedManager] increaseOrderItemCountAtIndex:index];
    
    cell.itemQuantityLabel.text = [NSString stringWithFormat:@"%ld", (long)count];
    [self startUpdatingPromoInfo];
    [self reloadCard];
    [self reloadContinueButton];
    
    [GANHelper analyzeEvent:@"Order_screen"
                      label:cell.orderItem.position.positionId
                   category:@"item_count_increase"];
}

- (void)orderItemCellDecreaseItemCount:(DBOrderItemCell *)cell{
    NSInteger index = [self.tableView indexPathForCell:cell].row;
    NSInteger count = [[OrderManager sharedManager] decreaseOrderItemCount:index];
    
    if(count == 0){
        [self removeRowAtIndex:index];
        
        [GANHelper analyzeEvent:@"Order_screen"
                          label:cell.orderItem.position.positionId
                       category:@"item_delete"];
    } else {
        cell.itemQuantityLabel.text = [NSString stringWithFormat:@"%ld", (long)count];
        
        [GANHelper analyzeEvent:@"Order_screen"
                          label:cell.orderItem.position.positionId
                       category:@"item_count_decrease"];
    }
    
    [self startUpdatingPromoInfo];
    [self reloadContinueButton];
    [self reloadCard];
}

- (void)orderItemCellSwipe:(DBOrderItemCell *)cell{
    [GANHelper analyzeEvent:@"Order_screen"
                      label:cell.orderItem.position.positionId
                   category:@"item_swipe"];
}

- (void)orderItemCell:(DBOrderItemCell *)cell newPreferedHeight:(NSInteger)height{
    NSInteger index = [self.tableView indexPathForCell:cell].row;
    
    if(index < [self.preferedHeightsForTableView count]){
        self.preferedHeightsForTableView[index] = @(height);
    }
}

- (void)orderItemCellReloadHeight:(DBOrderItemCell *)cell{
    [self reloadTableViewCellsHeight];
}

#pragma mark - CommentViewController

- (void)commentViewController:(DBCommentViewController *)controller didFinishWithText:(NSString *)text {
    [OrderManager sharedManager].comment = text;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - DBNewOrderNDAViewDelegate

- (void)db_newOrderNDAViewDidTapNDALabel:(DBNewOrderNDAView *)ndaView{
    DBHTMLViewController *ndaController = [DBHTMLViewController new];
    ndaController.title = NSLocalizedString(@"Политика", nil);
    ndaController.url = [NSURL URLWithString:@"http://empatika-doubleb.appspot.com/docs/nda.html"];
    ndaController.screen = @"NDA_screen";
    
    [self.navigationController pushViewController:ndaController animated:YES];
}

- (void)db_newOrderNDAView:(DBNewOrderNDAView *)ndaView didSelectSwitchState:(BOOL)on{
    [self reloadContinueButton];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController class] == [DBOrdersTableViewController class]) {
        [[OrderManager sharedManager] purgePositions];
    }
}

@end
