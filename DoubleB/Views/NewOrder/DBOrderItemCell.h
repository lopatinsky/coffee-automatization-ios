//
//  IHOrderTableViewCell.h
//  IIko Hackathon
//
//  Created by Balaban Alexander on 04/04/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OrderItem;

@class DBOrderItemCell;
@protocol DBOrderItemCellDelegate <NSObject>
@required
- (BOOL)db_orderItemCellCanEdit:(DBOrderItemCell *)cell;
- (void)db_orderItemCellIncreaseItemCount:(DBOrderItemCell *)cell;
- (void)db_orderItemCellDecreaseItemCount:(DBOrderItemCell *)cell;
- (void)db_orderItemCellSwipe:(DBOrderItemCell *)cell;
//@optional
//- (void)orderItemCell:(DBOrderItemCellOld *)cell newPreferedHeight:(NSInteger)height;
//- (void)orderItemCellReloadHeight:(DBOrderItemCellOld *)cell;
@end

@interface DBOrderItemCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *orderCellContentView;

@property (weak, nonatomic) IBOutlet UIImageView *positionImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *modifiersLabel;

@property (strong, nonatomic) OrderItem *orderItem;
@property (weak, nonatomic) id<DBOrderItemCellDelegate> delegate;
@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;

- (void)configureWithOrderItem:(OrderItem *)item;
- (void)itemInfoChanged:(BOOL)animated;
- (void)reloadCount;

- (void)moveContentToOriginal;
- (void)moveContentToLeft;

@end
