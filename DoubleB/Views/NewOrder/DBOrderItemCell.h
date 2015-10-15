//
//  IHOrderTableViewCell.h
//  IIko Hackathon
//
//  Created by Balaban Alexander on 04/04/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OrderItem;
@class DBPromoItem;
@class DBOrderItemCell;

typedef NS_ENUM(NSUInteger, DBOrderItemCellType) {
    DBOrderItemCellTypeCompact = 0,
    DBOrderItemCellTypeFull
};

@protocol DBOrderItemCellDelegate <NSObject>
@required
- (BOOL)db_orderItemCellCanEdit:(DBOrderItemCell *)cell;
- (void)db_orderItemCellIncreaseItemCount:(DBOrderItemCell *)cell;
- (void)db_orderItemCellDecreaseItemCount:(DBOrderItemCell *)cell;

@optional
- (void)db_orderItemCellSwipe:(DBOrderItemCell *)cell;

- (void)db_orderItemCellDidSelect:(DBOrderItemCell *)cell;
- (void)db_orderItemCellDidSelectDelete:(DBOrderItemCell *)cell;
- (void)db_orderItemCellDidSelectReplace:(DBOrderItemCell *)cell;
@end

@interface DBOrderItemCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *orderCellContentView;

@property (weak, nonatomic) IBOutlet UIImageView *positionImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *modifiersLabel;

@property (nonatomic, readonly) DBOrderItemCellType type;

@property (strong, nonatomic) OrderItem *orderItem;
@property (strong, nonatomic) DBPromoItem *promoItem;

@property (weak, nonatomic) id<DBOrderItemCellDelegate> delegate;
@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;

- (instancetype)initWithType:(DBOrderItemCellType)type;
- (void)configure;
- (void)reload;
- (void)reloadCount;

- (void)moveContentToOriginal:(BOOL)animated;
- (void)moveContentToLeft:(BOOL)animated;

@end
