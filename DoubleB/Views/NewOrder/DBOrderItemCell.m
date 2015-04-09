//
//  IHOrderTableViewCell.m
//  IIko Hackathon
//
//  Created by Balaban Alexander on 04/04/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBOrderItemCell.h"
#import "OrderItem.h"
#import "DBMenuPosition.h"
#import "DBMenuPositionModifier.h"
#import "DBMenuPositionModifierItem.h"
#import "DBOrderItemInactivityView.h"

#import "UIImageView+WebCache.h"

@interface DBOrderItemCell () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UIButton *lessButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingSpaceContentViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingSpaceContentViewConstraint;
@property (nonatomic) CGFloat itemCellContentViewOffset;

@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@property (strong, nonatomic) DBOrderItemInactivityView *inactivityView;
@end

@implementation DBOrderItemCell

- (void)awakeFromNib
{
    self.orderCellContentView.backgroundColor = [UIColor whiteColor];
    
    self.countLabel.textColor = [UIColor db_defaultColor];
    self.modifiersLabel.textColor = [UIColor db_defaultColor];
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    self.panGestureRecognizer.cancelsTouchesInView = NO;
    [self.orderCellContentView addGestureRecognizer:self.panGestureRecognizer];
    
    [self.contentView bringSubviewToFront:self.orderCellContentView];
    
    self.itemCellContentViewOffset = 0;
    
    [self.positionImageView db_showDefaultImage];
    
    [self addEditButtons];
    
    self.inactivityView = [DBOrderItemInactivityView new];
    [self.orderCellContentView addSubview:self.inactivityView];
    self.inactivityView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.inactivityView alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self.orderCellContentView];
    self.inactivityView.hidden = YES;
}

- (void)addEditButtons{
    [self.lessButton addTarget:self action:@selector(lessButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    self.lessButton.backgroundColor = [UIColor db_grayColor];
    [self.lessButton setTitle:@"-" forState:UIControlStateNormal];
    
    [self.moreButton addTarget:self action:@selector(moreButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    self.moreButton.backgroundColor = [UIColor db_defaultColor];
    [self.moreButton setTitle:@"+" forState:UIControlStateNormal];
}

- (void)configureWithOrderItem:(OrderItem *)item{
    self.orderItem = item;
    
    self.titleLabel.text = item.position.name;
    self.priceLabel.text = [NSString stringWithFormat:@"%.0f р.", item.position.actualPrice];
    [self reloadCount];
    
    if(item.position.imageUrl){
        [self.positionImageView sd_setImageWithURL:[NSURL URLWithString:item.position.imageUrl]
                                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                             if(!error){
                                                 [self.positionImageView db_hideDefaultImage];
                                             }
                                         }];
    }
    
    NSMutableString *modifiersString =[[NSMutableString alloc] init];
    
    for(DBMenuPositionModifier *modifier in item.position.groupModifiers){
        if(modifier.selectedItem){
            if(modifier.actualPrice > 0){
                [modifiersString appendString:[NSString stringWithFormat:@"+%.0f р. - %@ (%@)\n", modifier.actualPrice, modifier.selectedItem.itemName, modifier.modifierName]];
            } else {
                [modifiersString appendString:[NSString stringWithFormat:@"%@ (%@)\n", modifier.selectedItem.itemName, modifier.modifierName]];
            }
        }
    }
    
    for(DBMenuPositionModifier *modifier in item.position.singleModifiers){
        if(modifier.selectedCount > 0){
            if(modifier.actualPrice > 0){
                [modifiersString appendString:[NSString stringWithFormat:@"+%.0f р. - %@ (x%ld)\n", modifier.actualPrice, modifier.modifierName, (long)modifier.selectedCount]];
            } else {
                [modifiersString appendString:[NSString stringWithFormat:@"%@ (x%ld)\n", modifier.modifierName, (long)modifier.selectedCount]];
            }
        }
    }
    while (modifiersString.length > 0 && [modifiersString characterAtIndex:modifiersString.length - 1] == '\n')
        [modifiersString deleteCharactersInRange:NSMakeRange(modifiersString.length - 1, 1)];
    
    self.modifiersLabel.text = modifiersString;
}

// Called after every update of promos
- (void)itemInfoChanged:(BOOL)animated {
    if([_orderItem.errors count] > 0){
        [self.inactivityView setErrors:_orderItem.errors];
        
        if(self.inactivityView.hidden){
            self.inactivityView.alpha = 0;
            self.inactivityView.hidden = NO;
            if(animated){
                [UIView animateWithDuration:0.2 animations:^{
                    self.inactivityView.alpha = 1;
                }];
            } else {
                self.inactivityView.alpha = 1;
            }
        }
    } else {
        if(!self.inactivityView.hidden){
            if(animated){
                [UIView animateWithDuration:0.2 animations:^{
                    self.inactivityView.alpha = 0;
                } completion:^(BOOL finished) {
                    self.inactivityView.hidden = YES;
                }];
            } else {
                self.inactivityView.alpha = 0;
                self.inactivityView.hidden = YES;
            }
        }
    }
}

- (void)reloadCount{
    self.countLabel.text = [NSString stringWithFormat:@"x%ld", self.orderItem.count];
}

- (void)moveContentToOriginal{
    self.leadingSpaceContentViewConstraint.constant = self.itemCellContentViewOffset;
    self.trailingSpaceContentViewConstraint.constant = 0;
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.orderCellContentView layoutIfNeeded];
                     }
                     completion:nil];
}

- (void)moveContentToLeft{
    self.leadingSpaceContentViewConstraint.constant = -(self.lessButton.frame.size.width + self.moreButton.frame.size.width);
    self.trailingSpaceContentViewConstraint.constant = (self.lessButton.frame.size.width + self.moreButton.frame.size.width);
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.orderCellContentView layoutIfNeeded];
                     } completion:nil];
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    if([self.delegate db_orderItemCellCanEdit:self]){
        CGPoint translation = [recognizer translationInView:self.contentView];
        
        double leftPositionX = recognizer.view.frame.origin.x + translation.x;
        if(leftPositionX > self.itemCellContentViewOffset)
            leftPositionX = self.itemCellContentViewOffset;
        if(leftPositionX < self.itemCellContentViewOffset - (self.lessButton.frame.size.width + self.moreButton.frame.size.width))
            leftPositionX = self.itemCellContentViewOffset - (self.lessButton.frame.size.width + self.moreButton.frame.size.width);
        
        self.leadingSpaceContentViewConstraint.constant = leftPositionX;
        self.trailingSpaceContentViewConstraint.constant = self.itemCellContentViewOffset - leftPositionX;
        [recognizer setTranslation:CGPointMake(0, 0) inView:self.contentView];
        [recognizer.view layoutIfNeeded];
        
        if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled
            || recognizer.state == UIGestureRecognizerStateFailed) {
            CGPoint velocity = [recognizer velocityInView:self.contentView];
            if(velocity.x < 0)
                leftPositionX = self.itemCellContentViewOffset - (self.lessButton.frame.size.width + self.moreButton.frame.size.width);
            else
                leftPositionX = self.itemCellContentViewOffset;
            
            self.leadingSpaceContentViewConstraint.constant = leftPositionX;
            self.trailingSpaceContentViewConstraint.constant = self.itemCellContentViewOffset - leftPositionX;
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [recognizer.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                if(leftPositionX == self.itemCellContentViewOffset - (self.lessButton.frame.size.width + self.moreButton.frame.size.width))
                    [self.delegate db_orderItemCellSwipe:self];
            }];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (IBAction)moreButtonTouchUpInside:(id)sender{
    if([self.delegate respondsToSelector:@selector(db_orderItemCellIncreaseItemCount:)]){
        [self.delegate db_orderItemCellIncreaseItemCount:self];
    }
}

- (IBAction)lessButtonTouchUpInside:(id)sender{
    if([self.delegate respondsToSelector:@selector(db_orderItemCellDecreaseItemCount:)]){
        [self.delegate db_orderItemCellDecreaseItemCount:self];
    }
}


@end
