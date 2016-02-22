//
//  DBSubscriptionTableViewController.m
//  DoubleB
//
//  Created by Balaban Alexander on 21/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBSubscriptionTableViewController.h"
#import "DBSubscriptionManager.h"
#import "DBFGPaymentModule.h"
#import "DBSubscriptionTableViewCell.h"
#import "DBCardsManager.h"
#import "DBModuleHeaderView.h"

#import "DBModuleView.h"
#import "DBSubscriptionVariant.h"
#import "UIColor+Brandbook.h"
#import "UIAlertView+BlocksKit.h"
#import "GANHelper.h"
#import "IHSecureStore.h"

@interface DBSubscriptionTableViewController () <DBOwnerViewControllerProtocol>

@property (weak, nonatomic) IBOutlet DBModuleView *cardsModuleContainer;
@property (strong, nonatomic) DBFGPaymentModule *cardsModuleView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIView *separator;
@property (weak, nonatomic) IBOutlet UIView *separator2;

@property (strong, nonatomic) NSString *screenName;
@property (strong, nonatomic) NSArray *variants;

@end

@implementation DBSubscriptionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.variants = [NSArray new];
    
    [self configureViews];
    [self loadVariants];
}

- (void)viewWillAppear:(BOOL)animated {
    [GANHelper analyzeScreen:self.screenName];
    
    [self.cardsModuleContainer reload:YES];
    [self sizeHeaderToFit];
}

#pragma mark - User methods
- (void)sizeHeaderToFit {
    UIView *headerView = self.tableView.tableHeaderView;
    [headerView setNeedsLayout];
    [headerView layoutIfNeeded];
    
    CGFloat height = [headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    CGRect frame = headerView.frame;
    frame.size.height = height;
    headerView.frame = frame;
    
    self.tableView.tableHeaderView = headerView;
    
    UIView *footerView = self.tableView.tableFooterView;
    [footerView setNeedsLayout];
    [footerView layoutIfNeeded];
    
    height = [footerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    frame = footerView.frame;
    frame.size.height = height;
    footerView.frame = frame;
    
    self.tableView.tableFooterView = footerView;
}

- (void)configureViews {
    self.screenName = @"Abonement_screen";
    
    [self db_setTitle:NSLocalizedString(@"Абонемент", nil)];
    self.navigationController.navigationBar.topItem.title = @"";
    
    self.titleLabel.text = [DBSubscriptionManager sharedInstance].subscriptionScreenTitle;
    self.descriptionLabel.text = [DBSubscriptionManager sharedInstance].subscriptionScreenText;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"DBSubscriptionVariantCell" bundle:nil]
         forCellReuseIdentifier:@"variantCell"];
    UIView *backgroundView = [UIView new];
    backgroundView.backgroundColor = [UIColor db_backgroundColor];
    self.tableView.backgroundView = backgroundView;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100.0;
    
    DBModuleHeaderView *header = [DBModuleHeaderView new];
    header.title = NSLocalizedString(@"Выберите карту для оплаты", nil);
    [self.cardsModuleContainer.submodules addObject:header];
    self.cardsModuleView = [DBFGPaymentModule new];
    [self.cardsModuleContainer.submodules addObject:self.cardsModuleView];
    self.cardsModuleView.ownerViewController = self;
    [self.cardsModuleContainer layoutModules];
    self.cardsModuleView.analyticsCategory = self.screenName;
    
    [self.buyButton setTitle:NSLocalizedString(@"Купить", nil) forState:UIControlStateNormal];
    [self.buyButton addTarget:self action:@selector(clickOrderButton) forControlEvents:UIControlEventTouchUpInside];
    self.buyButton.backgroundColor = [UIColor db_defaultColor];
    self.buyButton.layer.cornerRadius = 5.;
    self.buyButton.clipsToBounds = YES;
    
    CGRect frame = self.separator.frame;
    frame.size.height = 1.0 / [UIScreen mainScreen].scale;
    self.separator.frame = frame;
    frame = self.separator2.frame;
    frame.size.height = 1.0 / [UIScreen mainScreen].scale;
    self.separator2.frame = frame;
    
    self.footerView.backgroundColor = [UIColor db_backgroundColor];
}

- (void)loadVariants {
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [[DBSubscriptionManager sharedInstance] checkSubscriptionVariants:^(NSArray *variants) {
        self.variants = variants;
        if (self.variants.count) {
            [DBSubscriptionManager sharedInstance].selectedVariant = self.variants[0];
            [GANHelper analyzeEvent:@"abonement_select" label:[self.variants[0] variantId] category:self.screenName];
        }
        [self.tableView reloadData];
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    } failure:^(NSString *errorMessage) {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Ошибка", nil) message:@"Произошла ошибка при проведении операции. Пожалуйста, попробуйте ещё раз."
                             cancelButtonTitle:NSLocalizedString(@"Отменить", nil)
                             otherButtonTitles:@[NSLocalizedString(@"Повторить", nil)] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                 if (buttonIndex == 1) {
                                     [GANHelper analyzeEvent:@"abonement_load_retry" label:errorMessage category:self.screenName];
                                     [self loadVariants];
                                 }
                             }];
    }];
}

- (void)clickOrderButton {
    if ([[DBCardsManager sharedInstance] cardsCount] == 0) {
        [GANHelper analyzeEvent:@"abonement_no_card_try" category:self.screenName];
        UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Ошибка", nil) message:NSLocalizedString(@"Пожалуйста, добавьте карту для оплаты", nil) cancelButtonTitle:@"OK" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
        }];
        [alert show];
    } else {
        [GANHelper analyzeEvent:@"abonement_payment_click" category:self.screenName];
        
        [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        [[DBSubscriptionManager sharedInstance] buySubscription:[DBSubscriptionManager sharedInstance].selectedVariant callback:^(BOOL success, NSString *errorMessage) {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            if (success) {
                [GANHelper analyzeEvent:@"abonement_payment_success" label:[IHSecureStore sharedInstance].clientId category:self.screenName];
                
                [self showAlert:@"Абонемент успешно оплачен"];
                [[DBSubscriptionManager sharedInstance] subscriptionInfo:^(NSArray *info) {
                    [self.delegate subscriptionViewControllerWillDissappear];
                    [self.navigationController popViewControllerAnimated:YES];
                } failure:^(NSString *errorMessage) {
                    [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Ошибка", nil) message:errorMessage cancelButtonTitle:@"OK" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        
                    }];
                }];
            } else {
                if (errorMessage) {
                    [self showError:errorMessage];
                    [GANHelper analyzeEvent:@"abonement_payment_failure" label:errorMessage category:self.screenName];
                } else {
                    [self showError:NSLocalizedString(@"NoInternetConnectionErrorMessage", nil)];
                    [GANHelper analyzeEvent:@"abonement_payment_failure" label:NSLocalizedString(@"NoInternetConnectionErrorMessage", nil) category:self.screenName];
                }
                [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Ошибка", nil) message:@"Произошла ошибка при проведении операции. Пожалуйста, попробуйте ещё раз."
                                     cancelButtonTitle:NSLocalizedString(@"Отменить", nil)
                                     otherButtonTitles:@[NSLocalizedString(@"Повторить", nil)] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (buttonIndex == 1) {
                        [GANHelper analyzeEvent:@"abonement_payment_retry" label:errorMessage category:self.screenName];
                        [self clickOrderButton];
                    }
                }];
            }
        }];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.variants count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBSubscriptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"variantCell" forIndexPath:indexPath];
    
    cell.titleLabel.text = [self.variants[indexPath.row] name];
    NSMutableAttributedString *attrInfo = [[NSMutableAttributedString alloc] initWithString:[self.variants[indexPath.row] variantDescription]];
    [attrInfo addAttribute:NSForegroundColorAttributeName value:[[UIColor blackColor] colorWithAlphaComponent:0.5]
                     range:NSMakeRange(0, [[self.variants[indexPath.row] variantDescription] length])];
    NSString *info = [NSString stringWithFormat:@"\n\nСтоимость: %0.0f%@ Дней: %ld Кружек: %ld", [self.variants[indexPath.row] price],
                      [Compatibility currencySymbol],(long)[self.variants[indexPath.row] period], (unsigned long)[self.variants[indexPath.row] count]];
    NSMutableAttributedString *attrInfo2 = [[NSMutableAttributedString alloc] initWithString:info];
    [attrInfo2 addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]
                     range:NSMakeRange(0, [info length])];
    
    [attrInfo appendAttributedString:attrInfo2];
    cell.desciptionLabel.attributedText = attrInfo;
    
    if ([[DBSubscriptionManager sharedInstance] selectedVariant] && [[DBSubscriptionManager sharedInstance] selectedVariant] == self.variants[indexPath.row]) {
        cell.tickImageView.hidden = NO;
    } else {
        cell.tickImageView.hidden = YES;
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [GANHelper analyzeEvent:@"abonement_select" label:[self.variants[indexPath.row] variantId] category:self.screenName];
    
    NSInteger index = indexPath.row;
    if ([DBSubscriptionManager sharedInstance].selectedVariant) {
        index = [self.variants indexOfObject:[DBSubscriptionManager sharedInstance].selectedVariant];
        [DBSubscriptionManager sharedInstance].selectedVariant = self.variants[indexPath.row];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [DBSubscriptionManager sharedInstance].selectedVariant = self.variants[indexPath.row];
    }
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - DBSettingsProtocol

- (id<DBSettingsItemProtocol>)settingsItem {
    DBSettingsItem *settingsItem = [DBSettingsItem new];
    
    settingsItem.name = @"subscriptionVC";
    settingsItem.iconName = @"subscription";
    settingsItem.title = NSLocalizedString(@"Абонемент", nil);
    settingsItem.eventLabel = @"subscription_click";
    settingsItem.viewController = self;
    settingsItem.navigationType = DBSettingsItemNavigationPush;
    
    return settingsItem;
}

@end
