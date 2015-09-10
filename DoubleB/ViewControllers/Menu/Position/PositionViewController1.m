//
//  DBPositionViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 03.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "PositionViewController1.h"
#import "DBMenuPosition.h"
#import "DBMenuPositionModifier.h"
#import "DBMenuPositionModifierItem.h"
#import "OrderCoordinator.h"
#import "DBBarButtonItem.h"
#import "DBPromoManager.h"
#import "DBPositionModifierCell.h"
#import "DBPositionModifierPicker.h"
#import "DBPositionModifiersList.h"

#import "UIView+RoundedCorners.h"
#import "UINavigationController+DBAnimation.h"
#import "UIImageView+WebCache.h"

@interface PositionViewController1 ()<DBPositionModifierPickerDelegate, DBPositionModifiersListDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *positionImageView;
@property (weak, nonatomic) IBOutlet UIImageView *defaultPositionImageView;
@property (weak, nonatomic) IBOutlet UILabel *positionTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *positionModifiersLabel;

@property (weak, nonatomic) IBOutlet UILabel *positionDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *priceButton;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightVolumeLabel;
@property (weak, nonatomic) IBOutlet UILabel *energyAmountLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *modifiersListContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintModifiersListContainerViewHeight;

@property (weak, nonatomic) IBOutlet UIView *imageSeparator;
@property (weak, nonatomic) IBOutlet UIView *tableTopSeparator;

@property (strong, nonatomic) DBPositionModifiersList *modifiersListView;
@property (strong, nonatomic) DBPositionModifierPicker *modifierPicker;

@end

@implementation PositionViewController1

+ (instancetype)initWithPosition:(DBMenuPosition *)position mode:(PositionViewControllerMode)mode {
    PositionViewController1 *positionVC = [PositionViewController1 new];
    
    positionVC.position = position;
    positionVC.mode = mode;
    
    return positionVC;
}

- (void)setParentNavigationController:(UINavigationController *)parentNavigationController {
    _parentNavigationController = parentNavigationController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self db_setTitle:self.position.name];
    
    self.positionImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.positionImageView alignLeading:@"0" trailing:@"0" toView:self.view];
    self.positionImageView.contentMode = [ViewManager defaultMenuPositionIconsContentMode];
    
    if(self.mode == PositionViewControllerModeMenuPosition){
        self.navigationItem.rightBarButtonItem = [[DBBarButtonItem alloc] initWithViewController:self action:@selector(goToOrderViewController)];
    }
    
    // Configure position image
    self.positionImageView.backgroundColor = [UIColor colorWithRed:200./255 green:200./255 blue:200./255 alpha:0.3f];
    self.defaultPositionImageView.hidden = NO;
    if(self.position.imageUrl){
        [self.positionImageView sd_setImageWithURL:[NSURL URLWithString:self.position.imageUrl]
                                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                             if(!error){
                                                 self.positionImageView.backgroundColor = [UIColor clearColor];
                                                 self.defaultPositionImageView.hidden = YES;
                                             }
                                         }];
    }
    
    self.positionTitleLabel.text = self.position.name;
    self.positionModifiersLabel.textColor = [UIColor db_defaultColor];
    [self reloadSelectedModifiers];
    self.positionDescriptionLabel.text = self.position.positionDescription;
    
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
    
    if (self.mode == PositionViewControllerModeMenuPosition){
        [self.priceLabel setRoundedCorners];
        self.priceLabel.backgroundColor = [UIColor db_defaultColor];
        self.priceLabel.textColor = [UIColor whiteColor];
        
        self.priceButton.enabled = YES;
    } else {
        self.priceLabel.backgroundColor = [UIColor clearColor];
        self.priceLabel.textColor = [UIColor db_defaultColor];
        
        self.priceButton.enabled = NO;
    }
    [self reloadPrice];
    
    self.imageSeparator.backgroundColor = [UIColor db_separatorColor];
    self.tableTopSeparator.backgroundColor = [UIColor db_separatorColor];
    
    self.modifiersListView = [DBPositionModifiersList new];
    [self.modifiersListView configureWithPosition:self.position];
    self.modifiersListView.delegate = self;
    [self.modifiersListContainer addSubview:self.modifiersListView];
    self.modifiersListView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.modifiersListView alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self.modifiersListContainer];
    self.constraintModifiersListContainerViewHeight.constant = self.modifiersListView.contentHeight;
    [self.scrollView layoutIfNeeded];
    
    self.modifierPicker = [DBPositionModifierPicker new];
    self.modifierPicker.delegate = self;
}

- (void)reloadSelectedModifiers{
    NSMutableString *modifiersString =[[NSMutableString alloc] init];
    
    for(DBMenuPositionModifier *modifier in self.position.groupModifiers){
        if(modifier.selectedItem){
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

- (void)reloadPrice{
    if (self.position.mode == DBMenuPositionModeRegular || self.position.mode == DBMenuPositionModeGift) {
        self.priceLabel.text = [NSString stringWithFormat:@"%.0f %@", self.position.actualPrice, [Compatibility currencySymbol]];
    }
    
    if (self.position.mode == DBMenuPositionModeBonus) {
        self.priceLabel.text = [NSString stringWithFormat:@"%.0f", self.position.price];
    }
}

- (IBAction)priceButtonClick:(id)sender {
    static BOOL clicked = false;
    if (clicked) { return; }
    clicked = true;
    [GANHelper analyzeEvent:@"product_price_click" label:[NSString stringWithFormat:@"%f", self.position.actualPrice] category:PRODUCT_SCREEN];
    [self.parentNavigationController animateAddProductFromView:self.priceLabel completion:^{
        if (self.position.mode == DBMenuPositionModeBonus) {
            [[OrderCoordinator sharedInstance].bonusItemsManager addPosition:self.position];
            if (self.position.price > [self totalPoints]) {
                self.priceButton.enabled = NO;
                self.priceLabel.alpha = 0.6;
            }
        } else {
            [[OrderCoordinator sharedInstance].itemsManager addPosition:self.position];
        }
        clicked = false;
    }];
}

- (void)goToOrderViewController{
    [self.parentNavigationController popToRootViewControllerAnimated:YES];
    [GANHelper analyzeEvent:@"order_pressed" category:PRODUCT_SCREEN];
}

- (double)totalPoints{
    return [OrderCoordinator sharedInstance].promoManager.bonusPointsBalance - [OrderCoordinator sharedInstance].bonusItemsManager.totalCount;
}

#pragma mark - DBPositionModifiersListDelegate

- (void)db_positionModifiersList:(DBPositionModifiersList *)list didSelectGroupModifier:(DBMenuPositionModifier *)modifier{
    [self.modifierPicker configureWithGroupModifier:modifier];
    self.modifierPicker.currencyDisplayMode = (self.position.mode == DBMenuPositionModeBonus) ? DBUICurrencyDisplayModeNone : DBUICurrencyDisplayModeRub;
    
    [self.modifierPicker showOnView:self.navigationController.view withAppearance:DBPopupViewComponentAppearanceModal];
    
    [GANHelper analyzeEvent:@"group_modifier_show"
                      label:modifier.modifierId
                   category:PRODUCT_SCREEN];
}

- (void)db_positionModifiersListDidSelectSingleModifiers:(DBPositionModifiersList *)list {
    [self.modifierPicker configureWithSingleModifiers:self.position.singleModifiers];
    self.modifierPicker.currencyDisplayMode = (self.position.mode == DBMenuPositionModeBonus) ? DBUICurrencyDisplayModeNone : DBUICurrencyDisplayModeRub;
    
    [self.modifierPicker showOnView:self.navigationController.view withAppearance:DBPopupViewComponentAppearanceModal];
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

@end
