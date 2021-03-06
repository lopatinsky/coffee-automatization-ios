//
//  IHProductTableViewCell.m
//  IIko Hackathon
//
//  Created by Balaban Alexander on 04/04/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBPositionCell.h"
#import "DBMenuPosition.h"
#import "DBTableItemInactivityView.h"
#import "ViewManager.h"

#import "UIView+RoundedCorners.h"

#import "UIImageView+WebCache.h"
#import "UIImageView+PINRemoteImage.h"

@interface DBPositionCell()
@property (weak, nonatomic) DBImageView *positionImageView;
@property (weak, nonatomic) UILabel *titleLabel;
@property (weak, nonatomic) UILabel *descriptionLabel;
@property (weak, nonatomic) UILabel *weightLabel;
@property (weak, nonatomic) UIView *separatorView;

@property (weak, nonatomic) IBOutlet UIImageView *basketImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *basketImageViewWidth;


@property (strong, nonatomic) DBTableItemInactivityView *inactivityView;
@end

@implementation DBPositionCell
@synthesize position = _position;

- (instancetype)initWithType:(DBPositionCellAppearanceType)type{
    if (type == DBPositionCellAppearanceTypeFull) {
        self = [self initFullCell];
    } else {
        self = [self initCompactCell];
    }
    _appearanceType = type;
    
    return self;
}

- (instancetype)init{
    self = [self initFullCell];
    return self;
}

- (instancetype)initFullCell {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBPositionCell" owner:self options:nil] firstObject];
    return self;
}

- (instancetype)initCompactCell {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBPositionCompactCell" owner:self options:nil] firstObject];
    return self;
}

+ (NSString *)reuseIdentifierFor:(DBPositionCellAppearanceType)type {
    if (type == DBPositionCellAppearanceTypeFull) {
        return @"DBPositionCell";
    } else {
        return @"DBPositionCompactCell";
    }
}

- (void)awakeFromNib
{
    [self initOutlets];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor whiteColor];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.positionImageView.contentMode = [ViewManager defaultMenuPositionIconsContentMode];
    self.positionImageView.noImageType = [DBCompanyInfo sharedInstance].type == DBCompanyTypeMobileShop ? DBImageViewNoImageTypeText : DBImageViewNoImageTypeImage;
    
    if ([[ApplicationConfig db_bundleName].lowercaseString isEqualToString:@"cosmotheca"] || [[ApplicationConfig db_bundleName].lowercaseString isEqualToString:@"cosmotest"]) {
        self.priceView.mode = DBPositionPriceViewModeStatic;
    } else {
        self.priceView.mode = DBPositionPriceViewModeInteracted;
        self.priceView.touchAction = ^void(){
            [self.delegate positionCellDidOrder:self];
            if (self.priceAnimated)
                [self.priceView animatePositionAdditionWithCompletion:nil];
        };
    }
    
    self.separatorView.backgroundColor = [UIColor db_separatorColor];
    
    if(_appearanceType == DBPositionCellAppearanceTypeFull){
        [self.positionImageView db_showDefaultImage];
    }
    
    self.inactivityView = [DBTableItemInactivityView new];
    
    UIImage *basketImage = [ViewManager basketImageMenuPosition];
    if (basketImage) {
        self.basketImageView.hidden = NO;
        self.basketImageViewWidth.constant = 20.0;
        self.basketImageView.image = [basketImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.basketImageView.tintColor = [UIColor db_defaultColor];
    } else {
        self.basketImageView.hidden = YES;
        self.basketImageViewWidth.constant = 0.0;
    }
}

- (void)initOutlets {
    self.positionImageView = (DBImageView *)[self.contentView viewWithTag:1];
    self.titleLabel = (UILabel *)[self.contentView viewWithTag:2];
    self.descriptionLabel = (UILabel *)[self.contentView viewWithTag:3];
    self.weightLabel = (UILabel *)[self.contentView viewWithTag:4];
    self.priceView = (DBPositionPriceView *)[self.contentView viewWithTag:5];
    self.separatorView = [self.contentView viewWithTag:6];
}

- (void)configureWithPosition:(DBMenuPosition *)position{
    _position = position;
    
    self.titleLabel.text = position.name;
    [self reloadPriceLabel];
    
    if(_appearanceType == DBPositionCellAppearanceTypeFull){
        self.descriptionLabel.text = position.positionDescription;
        if(position.weight == 0){
            self.weightLabel.hidden = YES;
        } else {
            self.weightLabel.text = [NSString stringWithFormat:@"%.0f %@", position.weight, NSLocalizedString(@"г", nil)];
            self.weightLabel.hidden = NO;
        }
        
        self.positionImageView.dbImageUrl = [NSURL URLWithString:position.imageUrl];
    }
}


- (void)reloadPriceLabel {
    if(self.contentType == DBPositionCellContentTypeBonus){
        self.priceView.title = [NSString stringWithFormat:@"%.0f", self.position.price];
    } else {
        self.priceView.title = [NSString stringWithFormat:@"%.0f %@", self.position.price, [Compatibility currencySymbol]];
    }
}

- (void)disable{
    self.inactivityView.frame = self.contentView.bounds;
    [self.inactivityView setErrors:nil];
    
    [self.contentView addSubview:self.inactivityView];
    [self setUserInteractionEnabled:NO];
}

- (void)enable{
    [self.inactivityView removeFromSuperview];
    [self setUserInteractionEnabled:YES];
}

#pragma mark - PositionCellProtocol
- (DBMenuPosition *)position {
    return _position;
}

@end
