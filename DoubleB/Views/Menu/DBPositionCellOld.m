//
//  DBPositionCell.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 07.12.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBPositionCellOld.h"
#import "IHSecureStore.h"

@interface DBPositionCellOld () <UIGestureRecognizerDelegate>

@end

@implementation DBPositionCellOld

- (void)awakeFromNib {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    tapGestureRecognizer.delegate = self;
    [self.positionTitleLabel addGestureRecognizer:tapGestureRecognizer];
    [self.plusLabel addGestureRecognizer:tapGestureRecognizer];
    [self.plusImageView templateImageWithName:@"add_position"];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    CGPoint point = [touch locationInView:self.contentView];
    
    if(CGRectContainsPoint(self.positionTitleLabel.frame, point)){
        [GANHelper analyzeEvent:@"item_title_click" label:self.positionTitleLabel.text category:@"Menu_screen"];
    }
    
    if(CGRectContainsPoint(self.plusLabel.frame, point)){
        [GANHelper analyzeEvent:@"item_plus_click" label:self.positionTitleLabel.text category:@"Menu_screen"];
    }
    
    return YES;
}


@end
