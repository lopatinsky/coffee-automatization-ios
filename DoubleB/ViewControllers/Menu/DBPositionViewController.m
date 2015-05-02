//
//  DBPositionViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 03.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBPositionViewController.h"
#import "DBMenuPosition.h"
#import "DBMenuPositionModifier.h"
#import "DBMenuPositionModifierItem.h"
#import "OrderManager.h"
#import "DBBarButtonItem.h"
#import "DBPositionModifierCell.h"
#import "DBPositionModifierPicker.h"
#import "Compatibility.h"

#import "UINavigationController+DBAnimation.h"
#import "UIImageView+WebCache.h"

@interface DBPositionViewController ()<UITableViewDataSource, UITableViewDelegate, DBPositionModifierPickerDelegate>
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

@property (weak, nonatomic) IBOutlet UITableView *modifiersTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintModifiersTableViewHeight;

@property (weak, nonatomic) IBOutlet UIView *imageSeparator;
@property (weak, nonatomic) IBOutlet UIView *tableTopSeparator;

@property (strong, nonatomic) DBPositionModifierPicker *modifierPicker;

@end

@implementation DBPositionViewController

- (instancetype)initWithPosition:(DBMenuPosition *)position mode:(DBPositionViewControllerMode)mode{
    self = [super init];
    
    self.position = position;
    self.mode = mode;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.positionImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.positionImageView alignLeading:@"0" trailing:@"0" toView:self.view];
    
    self.navigationItem.rightBarButtonItem = [[DBBarButtonItem alloc] initWithViewController:self action:@selector(goToOrderViewController)];
    
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
        self.weightVolumeLabel.text = [NSString stringWithFormat:@"%.0f %@", self.position.weight, NSLocalizedString(@"г.", nil)];
    }
    
    if(self.position.volume > 0){
        self.weightVolumeLabel.text = [NSString stringWithFormat:@"%.0f %@", self.position.volume, NSLocalizedString(@"мл.", nil)];
    }
    
    self.energyAmountLabel.text = @"";
    if(self.position.energyAmount > 0){
        self.energyAmountLabel.text = [NSString stringWithFormat:@"%.0f %@", self.position.energyAmount, NSLocalizedString(@"ккал.", nil)];
    }
    
    if(self.mode == DBPositionViewControllerModeMenuPosition){
        self.priceLabel.layer.cornerRadius = self.priceLabel.frame.size.height / 2;
        self.priceLabel.layer.masksToBounds = YES;
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
    
    self.modifiersTableView.dataSource = self;
    self.modifiersTableView.delegate = self;
    self.modifiersTableView.rowHeight = 40.f;
    [self.modifiersTableView reloadData];
    self.constraintModifiersTableViewHeight.constant = self.modifiersTableView.contentSize.height;
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
    self.priceLabel.text = [NSString stringWithFormat:@"%.0f %@", self.position.actualPrice, [Compatibility currencySymbol]];
}

- (IBAction)priceButtonClick:(id)sender {
    [GANHelper analyzeEvent:@"product_price_click" label:[NSString stringWithFormat:@"%f", self.position.actualPrice] category:PRODUCT_SCREEN];
    [self.navigationController animateAddProductFromView:self.priceLabel completion:^{
        [[OrderManager sharedManager] addPosition:self.position];
    }];
}

- (void)goToOrderViewController{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [GANHelper analyzeEvent:@"back_arrow_pressed" category:PRODUCT_SCREEN];
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
        [self.modifierPicker configureWithGroupModifier:self.position.groupModifiers[indexPath.row]];
        [GANHelper analyzeEvent:@"group_modifier_show"
                          label:((DBMenuPositionModifier *)self.position.groupModifiers[indexPath.row]).modifierId
                       category:PRODUCT_SCREEN];
    } else {
        [self.modifierPicker configureWithSingleModifiers:self.position.singleModifiers];
    }
    
    [self.modifierPicker showOnView:self.navigationController.view];
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
