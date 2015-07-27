//
//  PositionViewController.m
//  
//
//  Created by Balaban Alexander on 18/07/15.
//
//

#import "PositionViewController2.h"
#import "Compatibility.h"
#import "OrderManager.h"

#import "DBBarButtonItem.h"
#import "DBMenuPosition.h"
#import "DBMenuPositionModifier.h"
#import "DBMenuPositionModifierItem.h"
#import "DBPositionModifierPicker.h"
#import "DBPositionModifierCell.h"

#import "UIView+RoundedCorners.h"
#import "UIImageView+WebCache.h"
#import "UINavigationController+DBAnimation.h"

@interface PositionViewController2 () <UITableViewDataSource, UITableViewDelegate, DBPositionModifierPickerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *positionImageView;
@property (strong, nonatomic) IBOutlet UIImageView *defaultPositionImageView;
@property (weak, nonatomic) IBOutlet UILabel *positionTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *positionModifiersLabel;

@property (weak, nonatomic) IBOutlet UILabel *positionDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *priceButton;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightVolumeLabel;
@property (weak, nonatomic) IBOutlet UILabel *energyAmountLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UITableView *modifiersTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintModifiersTableViewHeight;

@property (weak, nonatomic) IBOutlet UIView *imageSeparator;
@property (weak, nonatomic) IBOutlet UIView *tableTopSeparator;
@property (strong, nonatomic) IBOutlet UIView *separator;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *separatorHeightConstraint;

@property (strong, nonatomic) DBPositionModifierPicker *modifierPicker;

@end

@implementation PositionViewController2

+ (instancetype)initWithPosition:(DBMenuPosition *)position mode:(PositionViewControllerMode)mode {
    PositionViewController2 *positionVC = [PositionViewController2 new];
    positionVC.position = position;
    positionVC.mode = mode;
    return positionVC;
}

- (void)setParentNavigationController:(UINavigationController *)controller {
    _parentNavigationController = controller;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.positionImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.positionImageView alignLeading:@"0" trailing:@"0" toView:self.view];
    
    if (self.mode == PositionViewControllerModeMenuPosition) {
        self.navigationItem.rightBarButtonItem = [[DBBarButtonItem alloc] initWithViewController:self action:@selector(goToOrderViewController)];
    }
    
    self.positionImageView.backgroundColor = [UIColor colorWithRed:200./255 green:200./255 blue:200./255 alpha:0.3f];
    self.defaultPositionImageView.hidden = NO;
    if (self.position.imageUrl) {
        [self.positionImageView sd_setImageWithURL:[NSURL URLWithString:self.position.imageUrl]
                                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                             if (!error) {
                                                 self.positionImageView.backgroundColor = [UIColor clearColor];
                                                 self.defaultPositionImageView.hidden = YES;
                                             }
                                         }];
    }
    
    self.separatorHeightConstraint.constant = 1./ [UIScreen mainScreen].scale;
    
    self.title = self.position.name;
    self.positionTitleLabel.text = self.position.name;
    self.positionModifiersLabel.textColor = [UIColor db_defaultColor];
    [self reloadSelectedModifiers];
    self.positionDescriptionLabel.text = [NSString stringWithFormat:@"Ингредиенты:\n%@", self.position.positionDescription];
    
    self.weightVolumeLabel.text = @"";
    
    if(self.position.weight > 0){
        self.weightVolumeLabel.text = [NSString stringWithFormat:@"%.0f %@", self.position.weight, NSLocalizedString(@"г", nil)];
    }
    
    if(self.position.volume > 0){
        self.weightVolumeLabel.text = [NSString stringWithFormat:@"%.0f %@", self.position.volume, NSLocalizedString(@"мл", nil)];
    }
    
    self.energyAmountLabel.text = @"";
    if(self.position.energyAmount > 0){
        self.energyAmountLabel.text = [NSString stringWithFormat:@"%.0f %@", self.position.energyAmount, NSLocalizedString(@"ккал", nil)];
    }
    
    if(self.mode == PositionViewControllerModeMenuPosition){
        [self.priceLabel setRoundedCorners];
        self.priceLabel.textColor = [UIColor whiteColor];
        self.priceButton.enabled = YES;
    } else {
        [self.priceLabel setRoundedCorners];
        self.priceLabel.textColor = [UIColor whiteColor];
        self.priceButton.enabled = NO;
    }
    [self reloadPrice];
    
    self.imageSeparator.backgroundColor = [UIColor db_separatorColor];
    self.tableTopSeparator.backgroundColor = [UIColor db_separatorColor];
    
    self.modifiersTableView.dataSource = self;
    self.modifiersTableView.delegate = self;
    self.modifiersTableView.rowHeight = 40.f;
    [self.modifiersTableView reloadData];
    self.constraintModifiersTableViewHeight.constant = self.modifiersTableView.contentSize.height;
    [self.scrollView layoutIfNeeded];
    
    self.modifierPicker = [DBPositionModifierPicker new];
    self.modifierPicker.delegate = self;
    self.modifierPicker.position = self.position;
}

- (void)reloadSelectedModifiers{
    NSMutableString *modifiersString =[[NSMutableString alloc] init];
    
    for (DBMenuPositionModifier *modifier in self.position.groupModifiers) {
        if (modifier.selectedItem) {
            if(modifier.actualPrice > 0){
                [modifiersString appendString:[NSString stringWithFormat:@"+%.0f %@ - %@ (%@)\n", modifier.actualPrice, [Compatibility currencySymbol], modifier.selectedItem.itemName, modifier.modifierName]];
            } else {
                [modifiersString appendString:[NSString stringWithFormat:@"%@ (%@)\n", modifier.selectedItem.itemName, modifier.modifierName]];
            }
        }
    }
    
    for(DBMenuPositionModifier *modifier in self.position.singleModifiers){
        if(modifier.selectedCount > 0){
            if(modifier.actualPrice > 0){
                [modifiersString appendString:[NSString stringWithFormat:@"+%.0f %@ - %@ (x%ld)\n", modifier.actualPrice, [Compatibility currencySymbol], modifier.modifierName, (long)modifier.selectedCount]];
            } else {
                [modifiersString appendString:[NSString stringWithFormat:@"%@ (x%ld)\n", modifier.modifierName, (long)modifier.selectedCount]];
            }
        }
    }
    while (modifiersString.length > 0 && [modifiersString characterAtIndex:modifiersString.length - 1] == '\n')
        [modifiersString deleteCharactersInRange:NSMakeRange(modifiersString.length - 1, 1)];
    
    self.positionModifiersLabel.text = modifiersString;
    [self reloadPrice];
}

- (void)reloadPrice {
    if (self.position.positionType == General) {
        self.priceLabel.text = [NSString stringWithFormat:@"%.0f %@", self.position.actualPrice, [Compatibility currencySymbol]];
    } else if (self.position.positionType == Bonus) {
        self.priceLabel.text = [NSString stringWithFormat:@"%.0f", [self.position.productDictionary[@"points"] floatValue]];
    }
}

- (IBAction)priceButtonClick:(id)sender {
    [GANHelper analyzeEvent:@"product_price_click" label:[NSString stringWithFormat:@"%f", self.position.actualPrice] category:PRODUCT_SCREEN];
    [self.parentNavigationController animateAddProductFromView:self.priceLabel completion:^{
        [[OrderManager sharedManager] addPosition:self.position];
    }];
}

- (void)goToOrderViewController{
    [self.parentNavigationController popToRootViewControllerAnimated:YES];
    [GANHelper analyzeEvent:@"order_pressed" category:PRODUCT_SCREEN];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return [self.position.groupModifiers count];
    } else {
        return [self.position.singleModifiers count] > 0 ? 1 : 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DBPositionModifierCell *cell = [self.modifiersTableView dequeueReusableCellWithIdentifier:@"DBPositionModifierCell"];
    if(!cell){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DBPositionModifierCell" owner:self options:nil] firstObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if(indexPath.section == 0){
        DBMenuPositionModifier *modifier = self.position.groupModifiers[indexPath.row];
        cell.modifierTitleLabel.text = modifier.modifierName;
    } else {
        cell.modifierTitleLabel.text = @"Добавки";
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        [self.modifierPicker configureGroupModifierAtIndexPath:indexPath];
        [GANHelper analyzeEvent:@"group_modifier_show"
                          label:((DBMenuPositionModifier *)self.position.groupModifiers[indexPath.row]).modifierId
                       category:PRODUCT_SCREEN];
    } else {
        [self.modifierPicker configureSingleModifiers];
    }
    
    [self.modifierPicker showOnView:self.parentNavigationController.view];
}

#pragma mark - DBPositionModifierPickerDelegate

- (void)db_positionModifierPickerDidChangeItemCount:(DBPositionModifierPicker *)picker{
    [self reloadSelectedModifiers];
}

- (void)db_positionModifierPicker:(DBPositionModifierPicker *)picker didSelectNewItem:(DBMenuPositionModifierItem *)item{
    [self reloadSelectedModifiers];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.modifierPicker hide];
    });
}


- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

@end
