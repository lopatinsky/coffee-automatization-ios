//
//  IHProductTableViewCell.h
//  IIko Hackathon
//
//  Created by Balaban Alexander on 04/04/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PositionCellProtocol.h"
#import "DBPositionPriceView.h"

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
@property (weak, nonatomic) DBPositionPriceView *priceView;

@property (nonatomic, readonly) DBPositionCellAppearanceType appearanceType;
@property (nonatomic) DBPositionCellContentType contentType;
@property (nonatomic) BOOL priceAnimated;

@property (strong, nonatomic, readonly) DBMenuPosition *position;

@property (nonatomic, weak) id<DBPositionCellDelegate> delegate;

- (instancetype)initWithType:(DBPositionCellAppearanceType)type;
+ (NSString *)reuseIdentifierFor:(DBPositionCellAppearanceType)type;

- (void)configureWithPosition:(DBMenuPosition *)position;

- (void)disable;
- (void)enable;
- (DBMenuPosition *)position;

@end
