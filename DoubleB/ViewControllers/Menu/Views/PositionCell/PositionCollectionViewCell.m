//
//  PositionCollectionViewCell.m
//  
//
//  Created by Balaban Alexander on 16/07/15.
//
//

#import "PositionCollectionViewCell.h"

#import "DBMenuPosition.h"

#import "UIImageView+WebCache.h"

@implementation PositionCollectionViewCell

- (void)configureWithPosition:(DBMenuPosition *)position {
    self.position = position;
    self.positionNameLabel.text = position.name;
    
    self.positionImageView.contentMode = [ViewManager defaultMenuIconsContentMode];
    [self.positionImageView db_showDefaultImage];
    [self.positionImageView sd_setImageWithURL:[NSURL URLWithString:position.imageUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!error) {
            [self.positionImageView db_hideDefaultImage];
        }
    }];
}

- (DBMenuPosition *)position {
    return _position;
}

@end
