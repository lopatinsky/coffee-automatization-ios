//
//  DBPositionCell.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 13.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBOrderItemCellOld;
@class OrderItem;

@protocol DBPOrderItemTableCellDelegate <NSObject>
@required
- (BOOL)orderItemCellCanEdit:(DBOrderItemCellOld *)cell;
- (void)orderItemCellIncreaseItemCount:(DBOrderItemCellOld *)cell;
- (void)orderItemCellDecreaseItemCount:(DBOrderItemCellOld *)cell;
- (void)orderItemCellSwipe:(DBOrderItemCellOld *)cell;
@optional
- (void)orderItemCell:(DBOrderItemCellOld *)cell newPreferedHeight:(NSInteger)height;
- (void)orderItemCellReloadHeight:(DBOrderItemCellOld *)cell;
@end

@interface DBOrderItemCellOld : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *itemCellContentView;
@property (weak, nonatomic) IBOutlet UILabel *itemTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemQuantityLabel;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UIButton *lessButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingSpaceContentViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingSpaceContentViewConstraint;


@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (strong, nonatomic) OrderItem *orderItem;
@property (weak, nonatomic) id<DBPOrderItemTableCellDelegate> delegate;

- (void)itemInfoChanged:(BOOL)animated;

- (void)showOrHideAdditionalInfo;

- (void)moveContentToOriginal;
- (void)moveContentToLeft;

//- (void)showAdditionalInfoMarkView;
//- (void)hideAdditionalInfoMarkView;

@end
