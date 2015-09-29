//
//  IHProductTableViewCell.h
//  IIko Hackathon
//
//  Created by Balaban Alexander on 04/04/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PositionCellProtocol.h"

@class DBPositionCell;
@class DBMenuPosition;

typedef NS_ENUM(NSUInteger, DBPositionCellAppearanceType) {
    DBPositionCellAppearanceTypeCompact = 0,
    DBPositionCellAppearanceTypeFull
};

typedef NS_ENUM(NSUInteger, DBPositionCellContentType) {
    DBPositionCellContentTypeRegular = 0,
    DBPositionCellContentTypeBonus
};


@interface DBPositionCell : UITableViewCell <PositionCellProtocol>
@property (weak, nonatomic) IBOutlet UIImageView *positionImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UIButton *orderButton;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@property (nonatomic, readonly) DBPositionCellAppearanceType appearanceType;
@property (nonatomic) DBPositionCellContentType contentType;

@property (strong, nonatomic, readonly) DBMenuPosition *position;

@property (nonatomic, weak) id<DBPositionCellDelegate> delegate;

- (instancetype)initWithType:(DBPositionCellAppearanceType)type;
+ (NSString *)reuseIdentifierFor:(DBPositionCellAppearanceType)type;

- (void)configureWithPosition:(DBMenuPosition *)position;

- (void)animatePositionAdditionWithCompletion:(void(^)())completion;

- (void)disable;
- (void)enable;
- (DBMenuPosition *)position;

@end
