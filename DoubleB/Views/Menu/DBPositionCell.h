//
//  IHProductTableViewCell.h
//  IIko Hackathon
//
//  Created by Balaban Alexander on 04/04/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBPositionCell;
@class DBMenuPosition;

@protocol DBPositionCellDelegate <NSObject>
-(void)positionCellDidOrder:(DBPositionCell *)cell;

@optional
-(void)positionCell:(DBPositionCell *)cell shouldSelectModifiersForPosition:(DBMenuPosition *)position;
@end

@interface DBPositionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *positionImageView;
@property (weak, nonatomic) IBOutlet UIImageView *positionDefaultImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UIButton *orderButton;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@property (strong, nonatomic) DBMenuPosition *position;

@property (nonatomic, weak) id<DBPositionCellDelegate> delegate;
@property (weak, nonatomic) UITableView *tableView;

- (void)configureWithPosition:(DBMenuPosition *)position;

@end
