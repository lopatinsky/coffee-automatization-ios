//
//  PositionCollectionViewCell.h
//  
//
//  Created by Balaban Alexander on 16/07/15.
//
//

#import <UIKit/UIKit.h>
#import "PositionCellProtocol.h"

@class DBMenuPosition;

@interface PositionCollectionViewCell : UICollectionViewCell <PositionCellProtocol>

@property (strong, nonatomic) IBOutlet UIImageView *positionImageView;
@property (strong, nonatomic) IBOutlet UILabel *positionNameLabel;

@property (strong, nonatomic) DBMenuPosition *position;

- (void)configureWithPosition:(DBMenuPosition *)position;
- (DBMenuPosition *)position;

@end
