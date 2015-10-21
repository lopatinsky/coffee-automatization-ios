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

#import "DBModuleView.h"
#import "DBSubscriptionVariant.h"
#import "UIColor+Brandbook.h"
#import "MBProgressHUD.h"

@interface DBSubscriptionTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet DBModuleView *cardsModuleContainer;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIView *separator;
@property (weak, nonatomic) IBOutlet UIView *separator2;

@property (strong, nonatomic) DBFGPaymentModule *cardsModuleView;
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

- (void)configureViews {
    [self.tableView registerNib:[UINib nibWithNibName:@"DBSubscriptionVariantCell" bundle:nil]
         forCellReuseIdentifier:@"variantCell"];
    [self db_setTitle:NSLocalizedString(@"Абонемент", nil)];
    self.navigationController.navigationBar.topItem.title = @"";
    self.screenName = @"subscription_screen";
    
    self.titleLabel.text = [DBSubscriptionManager sharedInstance].subscriptionScreenTitle;
    self.descriptionLabel.text = [DBSubscriptionManager sharedInstance].subscriptionScreenText;
    
    self.cardsModuleView = [DBFGPaymentModule new];
    [self.cardsModuleContainer.submodules addObject:self.cardsModuleView];
    self.cardsModuleView.ownerViewController = self;
    [self.cardsModuleContainer layoutModules];
    
    [self.buyButton setTitle:NSLocalizedString(@"Купить", nil) forState:UIControlStateNormal];
    [self.buyButton addTarget:self action:@selector(clickOrderButton) forControlEvents:UIControlEventTouchUpInside];
    self.buyButton.backgroundColor = [UIColor db_defaultColor];
    
    self.tableView.bounces = NO;
    CGRect frame = self.separator.frame;
    frame.size.height = 1.0 / [UIScreen mainScreen].scale;
    self.separator.frame = frame;
    frame = self.separator2.frame;
    frame.size.height = 1.0 / [UIScreen mainScreen].scale;
    self.separator2.frame = frame;
    self.buyButton.layer.cornerRadius = 5.;
    self.buyButton.clipsToBounds = YES;
    
    for (id view in self.footerView.subviews) {
        if ([NSStringFromClass([view class]) isEqualToString:@"UITableViewWrapperView"]) {
            if([view isKindOfClass:[UIScrollView class]]) {
                UIScrollView *scroll = (UIScrollView *) view;
                scroll.delaysContentTouches = NO;
            }
            break;
        }
    }
    
    self.footerView.backgroundColor = [UIColor db_backgroundColor];
    UIView *backgroundView = [UIView new];
    backgroundView.backgroundColor = [UIColor db_backgroundColor];
    self.tableView.backgroundView = backgroundView;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100.0;
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateView];
}

- (void)updateView {
    NSInteger headerSize = 2 * 10 + 30; // borders + gap between title and description
    CGFloat height = [self heightForText:[DBSubscriptionManager sharedInstance].subscriptionScreenText font:[UIFont systemFontOfSize:15.0f] withinWidth:320];
    headerSize += height;
    CGRect frame = self.headerView.frame;
    frame.size.height = headerSize;
    self.headerView.frame = frame;
    [self.headerView layoutIfNeeded];
    
    NSInteger footerSize = 58;
    footerSize += self.cardsModuleView.bounds.size.height;
    frame = self.footerView.frame;
    frame.size.height = footerSize;
    self.footerView.frame = frame;
    [self.footerView layoutIfNeeded];
}

- (CGFloat)heightForText:(NSString*)text font:(UIFont*)font withinWidth:(CGFloat)width {
    CGSize size = [text sizeWithAttributes:@{NSFontAttributeName:font}];
    CGFloat area = size.height * size.width;
    CGFloat height = roundf(area / width);
    return ceilf(height / font.lineHeight) * font.lineHeight;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadVariants {
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [[DBSubscriptionManager sharedInstance] checkSubscriptionVariants:^(NSArray *variants) {
        self.variants = variants;
        if (self.variants.count) {
            [DBSubscriptionManager sharedInstance].selectedVariant = self.variants[0];
        }
        [self.tableView reloadData];
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    } failure:^(NSString *errorMessage) {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        
    }];
}

- (void)clickOrderButton {
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [[DBSubscriptionManager sharedInstance] buySubscription:[DBSubscriptionManager sharedInstance].selectedVariant callback:^(BOOL success, NSString *errorMessage) {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        if (success) {
            [self showAlert:@"Абонемент успешно оплачен"];
            [[DBSubscriptionManager sharedInstance] subscriptionInfo:^(NSArray *info) {
                
            } failure:^(NSString *errorMessage) {
                
            }];
        } else {
            if (errorMessage) {
                [self showError:errorMessage];
            } else {
                [self showError:NSLocalizedString(@"NoInternetConnectionErrorMessage", nil)];
            }
        }
    }];
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
                      [Compatibility currencySymbol],[self.variants[indexPath.row] period], [self.variants[indexPath.row] count]];
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


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
