//
//  PositionCompactCollectionViewCell.h
//  
//
//  Created by Balaban Alexander on 18/07/15.
//
//

#import <UIKit/UIKit.h>
#import "PositionCellProtocol.h"

@class DBMenuPosition;

@interface PositionCompactCollectionViewCell : UICollectionViewCell <PositionCellProtocol>

@property (strong, nonatomic) IBOutlet UILabel *positionNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UIButton *orderButton;

@property (strong, nonatomic) DBMenuPosition *position;
@property (weak, nonatomic) id<DBPositionCellDelegate> delegate;

- (void)configureWithPosition:(DBMenuPosition *)position;
- (DBMenuPosition *)position;

@end
