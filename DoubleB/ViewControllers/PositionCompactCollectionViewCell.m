//
//  PositionCompactCollectionViewCell.m
//  
//
//  Created by Balaban Alexander on 18/07/15.
//
//

#import "PositionCompactCollectionViewCell.h"

#import "DBMenuPosition.h"

@implementation PositionCompactCollectionViewCell

- (void)configureWithPosition:(DBMenuPosition *)position {
    self.position = position;
    self.positionNameLabel.text = position.name;
}

@end
