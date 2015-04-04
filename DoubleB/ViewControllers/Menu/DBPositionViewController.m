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
#import "OrderManager.h"
#import "DBBarButtonItem.h"
#import "DBPositionModifierCell.h"
#import "DBPositionModifierPicker.h"

#import "UINavigationController+DBAnimation.h"
#import "UIImageView+WebCache.h"
#import "UIView+FLKAutoLayout.h"

@interface DBPositionViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *positionImageView;
@property (weak, nonatomic) IBOutlet UIImageView *defaultPositionImageView;
@property (weak, nonatomic) IBOutlet UILabel *positionTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *positionDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightVolumeLabel;
@property (weak, nonatomic) IBOutlet UILabel *energyAmountLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UITableView *modifiersTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintModifiersTableViewHeight;

@property (weak, nonatomic) IBOutlet UIView *imageSeparator;
@property (weak, nonatomic) IBOutlet UIView *tableTopSeparator;
@property (weak, nonatomic) IBOutlet UIView *tableBottomSeparator;

@property (strong, nonatomic) DBPositionModifierPicker *modifierPicker;

@end

@implementation DBPositionViewController

- (instancetype)initWithPosition:(DBMenuPosition *)position{
    self = [super init];
    
    self.position = position;
    
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
    self.positionDescriptionLabel.text = self.position.positionDescription;
    
    self.priceLabel.backgroundColor = [UIColor db_defaultColor];
    self.priceLabel.layer.cornerRadius = self.priceLabel.frame.size.height / 2;
    self.priceLabel.layer.masksToBounds = YES;
    self.priceLabel.textColor = [UIColor whiteColor];
    self.priceLabel.text = [NSString stringWithFormat:@"%.0f р.", self.position.price];
    
    self.weightVolumeLabel.text = @"";
    
    if(self.position.weight > 0){
        self.weightVolumeLabel.text = [NSString stringWithFormat:@"%.0f г.", self.position.weight];
    }
    
    if(self.position.volume > 0){
        self.weightVolumeLabel.text = [NSString stringWithFormat:@"%.0f мл.", self.position.volume];
    }
    
    self.energyAmountLabel.text = @"";
    if(self.position.energyAmount > 0){
        self.weightVolumeLabel.text = [NSString stringWithFormat:@"%.0f ккал.", self.position.energyAmount];
    }
    
    self.imageSeparator.backgroundColor = [UIColor db_separatorColor];
    self.tableTopSeparator.backgroundColor = [UIColor db_separatorColor];
    self.tableBottomSeparator.backgroundColor = [UIColor db_separatorColor];
    
    self.modifiersTableView.dataSource = self;
    self.modifiersTableView.delegate = self;
    self.modifiersTableView.rowHeight = 40.f;
    [self.modifiersTableView reloadData];
    self.constraintModifiersTableViewHeight.constant = self.modifiersTableView.contentSize.height;
    [self.scrollView layoutIfNeeded];
    
    self.modifierPicker = [DBPositionModifierPicker new];
}

- (IBAction)orderButtonClick:(id)sender {
    [self.navigationController animateAddProductFromView:self.priceLabel completion:^{
        [[OrderManager sharedManager] addPosition:self.position];
    }];
}

- (void)goToOrderViewController{
    [self.navigationController popToRootViewControllerAnimated:YES];
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
        
    } else {
        [self.modifierPicker configureWithSingleModifiers:self.position.singleModifiers];
        [self.modifierPicker showOnView:self.navigationController.view];
    }
}

@end
