//
//  PositionCompactCollectionViewCell.m
//  
//
//  Created by Balaban Alexander on 18/07/15.
//
//

#import "PositionCompactCollectionViewCell.h"
#import "DBMenuPosition.h"
#import "UIView+RoundedCorners.h"

@implementation PositionCompactCollectionViewCell

- (void)configureWithPosition:(DBMenuPosition *)position {
    self.position = position;
    self.positionNameLabel.text = position.name;
    self.priceLabel.text = [NSString stringWithFormat:@"%.0f %@", self.position.actualPrice, [Compatibility currencySymbol]];
}

- (IBAction)orderButtonPressed:(id)sender {
    [self animateAdditionWithCompletion:^{
        [self.delegate positionCellDidOrder:self];
    }];
}

- (void)animateAdditionWithCompletion:(void(^)())completion{
    UIView *view = [[UIView alloc] initWithFrame:self.orderButton.frame];
    view.backgroundColor = [[UIColor db_defaultColor] colorWithAlphaComponent:0.4];
    
    [self.contentView addSubview:view];
    
    self.orderButton.alpha = 0;
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         view.transform = CGAffineTransformMakeScale(1.5, 1.5);
                     }
                     completion:^(BOOL finished) {
                         [view removeFromSuperview];
                         
                         if(completion)
                             completion();
                     }];
    
    [UIView animateWithDuration:0.2
                          delay:0.1
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         view.alpha = 0;
                         self.orderButton.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         [view removeFromSuperview];
                     }];
}

#pragma mark - PositionCellProtocol
- (DBMenuPosition *)position {
    return _position;
}

@end
