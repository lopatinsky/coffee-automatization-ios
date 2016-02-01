//
//  PositionCollectionViewCell.m
//  
//
//  Created by Balaban Alexander on 16/07/15.
//
//

#import "PositionCollectionViewCell.h"

#import "DBMenuPosition.h"

#import "UIImageView+PINRemoteImage.h"

@implementation PositionCollectionViewCell

- (void)configureWithPosition:(DBMenuPosition *)position {
    self.position = position;
    self.positionNameLabel.text = position.name;
    
    self.positionImageView.contentMode = [ViewManager defaultMenuPositionIconsContentMode];
    self.positionImageView.image = nil;
    [self.positionImageView pin_setImageFromURL:[NSURL URLWithString:position.imageUrl]];
}

- (DBMenuPosition *)position {
    return _position;
}

@end
