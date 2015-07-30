//
//  IHOrderTableViewCell.m
//  IIko Hackathon
//
//  Created by Balaban Alexander on 04/04/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBOrderItemCell.h"
#import "Compatibility.h"
#import "OrderItem.h"
#import "DBPromoManager.h"
#import "DBMenuPosition.h"
#import "DBMenuPositionModifier.h"
#import "DBMenuPositionModifierItem.h"
#import "DBNewOrderItemErrorView.h"

#import "UIImageView+WebCache.h"

@interface DBOrderItemCell () <UIGestureRecognizerDelegate, DBNewOrderItemErorViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UIButton *lessButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingSpaceContentViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingSpaceContentViewConstraint;

@property (nonatomic) CGFloat rightOriginBound;
@property (nonatomic) CGFloat leftOriginBound;

@property (weak, nonatomic) IBOutlet UIView *separatorView;

@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@property (strong, nonatomic) DBNewOrderItemErrorView *errorView;
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
    
    self.errorView = [DBNewOrderItemErrorView new];
    self.errorView.delegate = self;
    
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

- (void)configure {
    [self reload];
    [self moveContentToOriginal:NO];
}

- (void)reload {
    self.titleLabel.text = _orderItem.position.name;
    
    if (self.orderItem.position.mode == DBMenuPositionModeRegular){
        self.priceLabel.text = [NSString stringWithFormat:@"%.0f %@", _orderItem.position.actualPrice, [Compatibility currencySymbol]];
        [self addEditButtons];
    }
    
    if (self.orderItem.position.mode == DBMenuPositionModeBonus) {
        self.priceLabel.text = NSLocalizedString(@"Бонус", nil);
    }
    
    if (self.orderItem.position.mode == DBMenuPositionModeGift) {
        self.priceLabel.text = NSLocalizedString(@"Подарок", nil);
    }
    
    [self reloadCount];
    
    NSMutableString *modifiersString =[[NSMutableString alloc] init];
    
    for (DBMenuPositionModifier *modifier in _orderItem.position.groupModifiers){
        if (modifier.selectedItem) {
            if (modifier.actualPrice > 0){
                [modifiersString appendString:[NSString stringWithFormat:@"+%.0f р. - %@ (%@)\n", modifier.actualPrice, modifier.selectedItem.itemName, modifier.modifierName]];
            } else {
                [modifiersString appendString:[NSString stringWithFormat:@"%@ (%@)\n", modifier.selectedItem.itemName, modifier.modifierName]];
            }
        }
    }
    
    for(DBMenuPositionModifier *modifier in _orderItem.position.singleModifiers){
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
        [self.positionImageView sd_setImageWithURL:[NSURL URLWithString:_orderItem.position.imageUrl]
                                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                             if(!error){
                                                 [self.positionImageView db_hideDefaultImage];
                                             }
                                         }];
    }
    
    
    if([_promoItem.errors count] > 0){
        self.errorView.mode = _promoItem.substitute ? DBNewOrderItemErrorViewModeReplace : DBNewOrderItemErrorViewModeDelete;
        self.errorView.message = [_promoItem.errors firstObject];
        
        [self.errorView showOnView:self.contentView inFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height - self.separatorView.frame.size.height)];
    } else {
        [self.errorView hide];
    }
    
    [self layoutIfNeeded];
}

- (void)reloadCount{
    self.countLabel.text = [NSString stringWithFormat:@"x%ld", (long)self.orderItem.count];
}

- (void)moveContentToOriginal:(BOOL)animated{
    self.leadingSpaceContentViewConstraint.constant = self.rightOriginBound;
    self.trailingSpaceContentViewConstraint.constant = -self.rightOriginBound;
    
    if(animated){
        [UIView animateWithDuration:0.25
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self.orderCellContentView layoutIfNeeded];
                         }
                         completion:nil];
    } else {
        [self.orderCellContentView layoutIfNeeded];
    }
}

- (void)moveContentToLeft:(BOOL)animated{
    self.leadingSpaceContentViewConstraint.constant = self.leftOriginBound;
    self.trailingSpaceContentViewConstraint.constant = -self.leftOriginBound;
    
    if(animated){
        [UIView animateWithDuration:0.25
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self.orderCellContentView layoutIfNeeded];
                         }
                         completion:nil];
    } else {
        [self.orderCellContentView layoutIfNeeded];
    }
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
                [self moveContentToLeft:YES];
                [self.delegate db_orderItemCellSwipe:self];
            } else {
                [self moveContentToOriginal:YES];
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
    [GANHelper analyzeEvent:@"position_add_click" category:ORDER_SCREEN];
    if([self.delegate respondsToSelector:@selector(db_orderItemCellIncreaseItemCount:)]){
        [self.delegate db_orderItemCellIncreaseItemCount:self];
    }
}

- (IBAction)lessButtonTouchUpInside:(id)sender{
    [GANHelper analyzeEvent:@"position_minus_click" category:ORDER_SCREEN];
    if([self.delegate respondsToSelector:@selector(db_orderItemCellDecreaseItemCount:)]){
        [self.delegate db_orderItemCellDecreaseItemCount:self];
    }
}

#pragma mark - DBNewOrderItemErorViewDelegate

- (void)db_newOrderItemErrorViewDidTap:(DBNewOrderItemErrorView *)view{
    if(view.isOpen){
        [view moveContentRight];
    } else {
        [view moveContentLeft];
    }
    
    [GANHelper analyzeEvent:@"position_inactivity_view_click"
                      label:_orderItem.position.positionId
                   category:ORDER_SCREEN];
}

- (void)db_newOrderItemErrorView:(DBNewOrderItemErrorView *)view didSelectAction:(DBNewOrderItemErrorViewMode)actionMode{
    if(actionMode == DBNewOrderItemErrorViewModeDelete){
        if([self.delegate respondsToSelector:@selector(db_orderItemCellDidSelectDelete:)]){
            [self.delegate db_orderItemCellDidSelectDelete:self];
        }
    } else {
        if([self.delegate respondsToSelector:@selector(db_orderItemCellDidSelectReplace:)]){
            [self.delegate db_orderItemCellDidSelectReplace:self];
        }
    }
}


@end
