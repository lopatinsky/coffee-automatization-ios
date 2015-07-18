//
//  PositionCompactCollectionViewCell.h
//  
//
//  Created by Balaban Alexander on 18/07/15.
//
//

#import <UIKit/UIKit.h>

@class DBPositionCell;
@class DBMenuPosition;

@interface PositionCompactCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel *positionNameLabel;

@property (strong, nonatomic) DBMenuPosition *position;

- (void)configureWithPosition:(DBMenuPosition *)position;

@end
