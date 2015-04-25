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

@property (nonatomic) CGFloat rightOriginBound;
@property (nonatomic) CGFloat leftOriginBound;

@property (weak, nonatomic) IBOutlet UIView *separatorView;

@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@property (strong, nonatomic) DBOrderItemInactivityView *inactivityView;
@end

@implementation DBOrderItemCell

- (instancetype)initWithType:(DBOrderItemCellType)type{
    NSString *nibIdentifier;
    if (type == DBOrderItemCellTypeCompact) {
        nibIdentifier = @"DBOrderItemCompactCell";
    } else {
        nibIdentifier = @"DBOrderItemCell";
    }
    
    self = [[[NSBundle mainBundle] loadNibNamed:nibIdentifier owner:self options:nil] firstObject];
    _type = type;
    
    return self;
}

- (void)awakeFromNib
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.orderCellContentView.backgroundColor = [UIColor whiteColor];
    
    self.separatorView.backgroundColor = [UIColor db_separatorColor];
    
    self.countLabel.textColor = [UIColor db_defaultColor];
    self.modifiersLabel.textColor = [UIColor db_defaultColor];
    self.priceLabel.textColor = [UIColor db_defaultColor];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    self.tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.orderCellContentView addGestureRecognizer:self.tapGestureRecognizer];
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    self.panGestureRecognizer.cancelsTouchesInView = NO;
    [self.orderCellContentView addGestureRecognizer:self.panGestureRecognizer];
    
    [self addEditButtons];
    
    self.inactivityView = [DBOrderItemInactivityView new];
    self.inactivityView.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.7f];
    [self.orderCellContentView addSubview:self.inactivityView];
    self.inactivityView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.inactivityView alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self.orderCellContentView];
    self.inactivityView.hidden = YES;
    
    self.rightOriginBound = self.leadingSpaceContentViewConstraint.constant;
    self.leftOriginBound = self.rightOriginBound - (self.lessButton.frame.size.width + self.moreButton.frame.size.width);
    
    if(self.type == DBOrderItemCellTypeFull){
        [self.positionImageView db_showDefaultImage];
    }
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
    self.leadingSpaceContentViewConstraint.constant = 0;
    self.trailingSpaceContentViewConstraint.constant = 0;
    
    self.orderItem = item;
    
    self.titleLabel.text = item.position.name;
    self.priceLabel.text = [NSString stringWithFormat:@"%.0f р.", item.position.actualPrice];
    [self reloadCount];
    
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
    
    if(self.type == DBOrderItemCellTypeFull){
        [self.positionImageView db_showDefaultImage];
        [self.positionImageView sd_setImageWithURL:[NSURL URLWithString:item.position.imageUrl]
                                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                             if(!error){
                                                 [self.positionImageView db_hideDefaultImage];
                                             }
                                         }];
    }
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
    self.countLabel.text = [NSString stringWithFormat:@"x%ld", (long)self.orderItem.count];
}

- (void)moveContentToOriginal{
    self.leadingSpaceContentViewConstraint.constant = self.rightOriginBound;
    self.trailingSpaceContentViewConstraint.constant = -self.rightOriginBound;
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.orderCellContentView layoutIfNeeded];
                     }
                     completion:nil];
}

- (void)moveContentToLeft{
    self.leadingSpaceContentViewConstraint.constant = self.leftOriginBound;
    self.trailingSpaceContentViewConstraint.constant = -self.leftOriginBound;
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

        CGPoint velocity = [recognizer velocityInView:self.contentView];
//        if(fabs(velocity.x) > fabs(velocity.y) && fabs(velocity.x) > 50){
//            if([self.delegate respondsToSelector:@selector(db_orderItemCellDidStartSwipe:)]){
//                [self.delegate db_orderItemCellDidStartSwipe:self];
//            }
//        } else {
//            if(recognizer.state != UIGestureRecognizerStateEnded && recognizer.state != UIGestureRecognizerStateCancelled && recognizer.state != UIGestureRecognizerStateFailed ){
//                return;
//            }
//        }
        
        double leftPositionX = recognizer.view.frame.origin.x + translation.x;

        if(leftPositionX > self.rightOriginBound)
            leftPositionX = self.rightOriginBound;
        if(leftPositionX < self.leftOriginBound)
            leftPositionX = self.leftOriginBound;
        
        self.leadingSpaceContentViewConstraint.constant = leftPositionX;
        self.trailingSpaceContentViewConstraint.constant = self.rightOriginBound - leftPositionX;
        [recognizer setTranslation:CGPointMake(0, 0) inView:self.contentView];

        [recognizer.view layoutIfNeeded];
        
        if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed) {
            //            CGPoint velocity = [recognizer velocityInView:self.contentView];
            
            if(velocity.x < 0){
                [self moveContentToLeft];
                [self.delegate db_orderItemCellSwipe:self];
            } else {
                [self moveContentToOriginal];
            }
        }
    }
}

- (IBAction)handleTap:(UITapGestureRecognizer *)recognizer{
    if([self.delegate respondsToSelector:@selector(db_orderItemCellDidSelect:)]){
        [self.delegate db_orderItemCellDidSelect:self];
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
