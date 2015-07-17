//
//  PositionCollectionViewCell.h
//  
//
//  Created by Balaban Alexander on 16/07/15.
//
//

#import <UIKit/UIKit.h>

@class DBPositionCell;
@class DBMenuPosition;

@interface PositionCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *positionImageView;
@property (strong, nonatomic) IBOutlet UILabel *positionNameLabel;

@property (strong, nonatomic) DBMenuPosition *position;

- (void)configureWithPosition:(DBMenuPosition *)position;

@end
