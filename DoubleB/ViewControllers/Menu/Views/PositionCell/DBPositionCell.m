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

#import "UIView+RoundedCorners.h"
#import "UIImageView+PINRemoteImage.h"

@interface DBPositionCell()
@property (weak, nonatomic) UIImageView *positionImageView;
@property (weak, nonatomic) UILabel *titleLabel;
@property (weak, nonatomic) UILabel *descriptionLabel;
@property (weak, nonatomic) UILabel *weightLabel;
@property (weak, nonatomic) UIView *separatorView;


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
    
    self.priceView.mode = DBPositionPriceViewModeInteracted;
    self.priceView.touchAction = ^void(){
        [self.delegate positionCellDidOrder:self];
        if (self.priceAnimated)
            [self.priceView animatePositionAdditionWithCompletion:nil];
    };
    
    self.separatorView.backgroundColor = [UIColor db_separatorColor];
    
    if(_appearanceType == DBPositionCellAppearanceTypeFull){
        [self.positionImageView db_showDefaultImage];
    }
    
    self.inactivityView = [DBTableItemInactivityView new];
}

- (void)initOutlets {
    self.positionImageView = (UIImageView *)[self.contentView viewWithTag:1];
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
        
        self.positionImageView.contentMode = [ViewManager defaultMenuPositionIconsContentMode];
        
        self.positionImageView.image = nil;
        [self.positionImageView db_showDefaultImage];
        [self.positionImageView setPin_updateWithProgress:YES];
        [self.positionImageView pin_setImageFromURL:[NSURL URLWithString:position.imageUrl] completion:^(PINRemoteImageManagerResult *result) {
            if (result.resultType != PINRemoteImageResultTypeNone) {
                [self.positionImageView db_hideDefaultImage];
            }
        }];
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
