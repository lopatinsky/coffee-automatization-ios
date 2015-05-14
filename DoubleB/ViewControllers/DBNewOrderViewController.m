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
#import "DBServerAPI.h"
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
#import "DBPositionViewController.h"
#import "DBConstants.h"
#import "DBAddressViewController.h"
#import "DBDeliveryViewController.h"

#import <Parse/Parse.h>
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import <BlocksKit/UIGestureRecognizer+BlocksKit.h>
#import <BlocksKit/UIControl+BlocksKit.h>

NSString *const kDBDefaultsFaves = @"kDBDefaultsFaves";

#define TAG_OVERLAY 333

@interface DBNewOrderViewController () <UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, DBVenuesTableViewControllerDelegate, DBCardsViewControllerDelegate, DBCommentViewControllerDelegate, DBOrderItemCellDelegate, DBPromoManagerUpdateInfoDelegate, DBTimePickerViewDelegate, DBNewOrderNDAViewDelegate>

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

@property (strong, nonatomic) DBPositionsViewController *positionsViewController;

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
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.itemCells = [NSMutableArray new];
    self.preferedHeightsForTableView = [NSMutableArray new];
    
//    UINib *nib =[UINib nibWithNibName:@"DBOrderItemCell" bundle:[NSBundle mainBundle]];
//    [self.tableView registerNib:nib forCellReuseIdentifier:@"DBOrderItemCell"];
//    
//    nib =[UINib nibWithNibName:@"DBOrderItemNotesCell" bundle:[NSBundle mainBundle]];
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
    [[DBPromoManager sharedManager] synchronizeWalletInfo:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [GANHelper analyzeScreen:ORDER_SCREEN];
    
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

- (void)setupAddProductButton{
    [self.addProductImageView templateImageWithName:@"plus"];
    [self.addProductButton addTarget:self action:@selector(clickAddProductButton) forControlEvents:UIControlEventTouchUpInside];
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

//- (void)reloadTableViewCellsHeight{
//    [self.tableView beginUpdates];
//    [self reloadTableViewHeight:YES];
//    [self.tableView endUpdates];
//}

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
        timeString = [NSString stringWithFormat:@"%@ | %@", timeString, NSLocalizedString(@"На месте", nil)];
    }
    
    self.orderFooter.labelTime.text = timeString;
}

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
            if ([OrderManager sharedManager].totalPrice > [DBPromoManager sharedManager].walletBalance) {
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
                
                [Venue fetchVenuesForLocation:location withCompletionHandler:^(NSArray *venues) {

                    long interval = (long)-[start timeIntervalSinceNow];

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

    [self moveBack];
}

- (void)clickAddProductButton{
    if(!self.positionsViewController){
        self.positionsViewController = [DBPositionsViewController new];
        self.positionsViewController.hidesBottomBarWhenPushed = YES;
    }
    
    [GANHelper analyzeEvent:@"plus_click" category:ORDER_SCREEN];
    
    [self.navigationController pushViewController:self.positionsViewController animated:YES];
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

- (IBAction)clickAddress:(id)sender {
    [GANHelper analyzeEvent:@"venues_click" category:ORDER_SCREEN];
    DBVenuesTableViewController *venuesController = [DBVenuesTableViewController new];
    venuesController.delegate = self;
    venuesController.venues = self.venues;
    venuesController.hidesBottomBarWhenPushed = YES;
    
    DBDeliveryViewController *deliveryController = [DBDeliveryViewController new];
    
    NSArray *controllers = [NSArray arrayWithObjects:venuesController, deliveryController, nil];
    
    DBAddressViewController *deliveryVC = [[DBAddressViewController alloc] initWithControllers:controllers];
    deliveryVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:deliveryVC animated:YES];
    
//    [self.navigationController pushViewController:venuesController animated:YES];
}

- (IBAction)clickTime:(id)sender {
    [GANHelper analyzeEvent:@"time_click" category:ORDER_SCREEN];
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
    
    [GANHelper analyzeEvent:@"payment_click" label:label category:ORDER_SCREEN];

    DBCardsViewController *cardsController = [DBCardsViewController new];
    cardsController.mode = CardsViewControllerModeChoosePayment;
    cardsController.delegate = self;
    cardsController.screen = @"Cards_payment_screen";
    [self.navigationController pushViewController:cardsController animated:YES];
}

- (IBAction)clickComment:(id)sender {
    [GANHelper analyzeEvent:@"comment_screen" category:ORDER_SCREEN];
    DBCommentViewController *commentController = [DBCommentViewController new];
    commentController.delegate = self;
    commentController.comment = [OrderManager sharedManager].comment;
    [self.navigationController pushViewController:commentController animated:YES];
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

- (IBAction)clickPickerDone:(id)sender {
    [GANHelper analyzeEvent:@"time_spinner_closed" category:ORDER_SCREEN];
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
    rect.size.width = self.tabBarController.view.bounds.size.width;
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

- (void)sendOrder{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [DBServerAPI createNewOrder:^(Order *order) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [self.preferedHeightsForTableView removeAllObjects];
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
    if([OrderManager sharedManager].positionsCount > 0){
        [self.totalView startUpdating];
        
        [self reloadContinueButton];
        [[DBPromoManager sharedManager] updateInfo];
    }
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
        DBMenuPosition *templatePosition = itemInfo[@"item"];
        OrderItem *item = [[OrderManager sharedManager] itemWithTemplatePosition:templatePosition];
        item.notes = itemInfo[@"promos"];
        item.errors = itemInfo[@"errors"];
        
        NSInteger index = [[OrderManager sharedManager].items indexOfObject:item];
        DBOrderItemCell *cell = (DBOrderItemCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        [cell itemInfoChanged:YES];
    }
}


#pragma mark - DBPromoManagerDelegate

- (void)promoManager:(DBPromoManager *)manager
       didUpdateInfo:(NSArray *)itemsInfo
          promos:(NSArray *)promos{
    [self applyItemsInfo:itemsInfo];
    [self showOrHideAdditionalInfoViewWithErrors:nil promos:promos];
    
    [self endUpdatingPromoInfo];
}

- (void)promoManager:(DBPromoManager *)manager
       didUpdateInfo:(NSArray *)itemsInfo
          errors:(NSArray *)errors
          promos:(NSArray *)promos{
    [self applyItemsInfo:itemsInfo];
    [self showOrHideAdditionalInfoViewWithErrors:errors promos:promos];
    
    [self endUpdatingPromoInfo];
}

- (void)promoManager:(DBPromoManager *)mamager didFailUpdateInfoWithError:(NSError *)error{
    [self applyItemsInfo:nil];
    [self endUpdatingPromoInfo];
    
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
    [self startUpdatingPromoInfo];
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
    [GANHelper analyzeEvent:@"time_spinner_selected" category:ORDER_SCREEN];
    [OrderManager sharedManager].time = self.timeOptions[row];
    [self reloadTime];
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
    DBOrderItemCell *cell;
    
    OrderItem *item = [[OrderManager sharedManager] itemAtIndex:indexPath.row];
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
    
    [cell configureWithOrderItem:item];
    cell.delegate = self;
    cell.panGestureRecognizer.delegate = self;
    
//    BOOL isTheSame = false;
//    for (DBOrderItemCell *oldCell in self.itemCells) {
//        if (oldCell == cell) {
//            isTheSame = true;
//            break;
//        }
//    }
//    if (!isTheSame) {
//        [self.itemCells addObject:cell];
//    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row >= [self.preferedHeightsForTableView count]){
        CGFloat height;
        OrderItem *item = [[OrderManager sharedManager] itemAtIndex:indexPath.row];
        if(item.position.hasImage){
            height = 100;
        } else {
            height = 60;
        }
        
        [self.preferedHeightsForTableView addObject:@(height)];
        return height;
    } else {
        return [self.preferedHeightsForTableView[indexPath.row] floatValue];
    }
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [GANHelper analyzeEvent:@"item_title_click" category:ORDER_SCREEN];
//    
//    DBOrderItemCell *cell = (DBOrderItemCell *)[self.tableView cellForRowAtIndexPath:indexPath];
//    [cell showOrHideAdditionalInfo];
//    [self reloadTableViewCellsHeight];
//}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

#pragma mark - DBOrderItemCellDelegate

- (BOOL)db_orderItemCellCanEdit:(DBOrderItemCell *)cell{
    return YES;
}

- (void)removeRowAtIndex:(NSInteger)index{
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
    NSInteger count = [[OrderManager sharedManager] decreaseOrderItemCount:index];
    
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

//- (void)orderItemCell:(DBOrderItemCell *)cell newPreferedHeight:(NSInteger)height{
//    NSInteger index = [self.tableView indexPathForCell:cell].row;
//    
//    if(index < [self.preferedHeightsForTableView count]){
//        self.preferedHeightsForTableView[index] = @(height);
//    }
//}
//
//- (void)orderItemCellReloadHeight:(DBOrderItemCell *)cell{
//    [self reloadTableViewCellsHeight];
//}

- (void)db_orderItemCellDidSelect:(DBOrderItemCell *)cell{
    OrderItem *item = cell.orderItem;
    DBPositionViewController *positionVC = [[DBPositionViewController alloc] initWithPosition:item.position mode:DBPositionViewControllerModeOrderPosition navigationController:self.navigationController];
    [self.navigationController pushViewController:positionVC animated:YES];
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
    
    [GANHelper analyzeEvent:@"confidece_show" category:ORDER_SCREEN];
    
    [self.navigationController pushViewController:ndaController animated:YES];
}

- (void)db_newOrderNDAView:(DBNewOrderNDAView *)ndaView didSelectSwitchState:(BOOL)on{
    [self reloadContinueButton];
    if (on) {
        [GANHelper analyzeEvent:@"accept_policy" category:ORDER_SCREEN];
    } else {
        [GANHelper analyzeEvent:@"decline_policy" category:ORDER_SCREEN];
    }
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController class] == [DBOrdersTableViewController class]) {
        [[OrderManager sharedManager] purgePositions];
    }
}

@end
