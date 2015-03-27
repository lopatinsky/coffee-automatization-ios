//
//  DBPositionCell.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 13.10.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBOrderItemCell.h"
#import "IHSecureStore.h"
#import "OrderItem.h"
#import "DBOrderItemNotesCell.h"
#import "UIView+DBErrorAnimation.h"


@interface DBOrderItemCell () <UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *additonalInfoButton;
@property (weak, nonatomic) IBOutlet UIView *additionalInfoMarkView;
@property (weak, nonatomic) IBOutlet UIImageView *infoImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingSpaceItemTitleConstraint;

@property (nonatomic) CGFloat itemCellContentViewOffset;

@property (strong, nonatomic) UITableView *notesTableView;
@property (strong, nonatomic) NSLayoutConstraint *notesTableViewHeightConstraint;

@property (nonatomic) BOOL notesOpened;
@end

@implementation DBOrderItemCell

- (void)awakeFromNib {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    tapGestureRecognizer.delegate = self;
    [self.itemTitleLabel addGestureRecognizer:tapGestureRecognizer];
    [self.itemQuantityLabel addGestureRecognizer:tapGestureRecognizer];
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    self.panGestureRecognizer.cancelsTouchesInView = NO;
    [self.itemCellContentView addGestureRecognizer:self.panGestureRecognizer];
    
    [self.additonalInfoButton addTarget:self action:@selector(additionalInfoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.additionalInfoMarkView.hidden = YES;
    self.itemCellContentViewOffset = 0;
    
    self.additionalInfoMarkView.backgroundColor = [UIColor db_blueColor];

    self.notesTableView = [[UITableView alloc] initWithFrame:CGRectZero];
    self.notesTableView.scrollEnabled = NO;
    self.notesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.contentView insertSubview:self.notesTableView atIndex:0];
    self.clipsToBounds = YES;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[myView]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:@{@"myView":self.notesTableView}]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[myView]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:@{@"myView":self.notesTableView}]];
  
    self.notesTableViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.notesTableView
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0
                                                                        constant:[_orderItem.messages count] * 50];
    [self.contentView addConstraint:self.notesTableViewHeightConstraint];

    [self.notesTableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.notesTableView.delegate = self;
    self.notesTableView.dataSource = self;
    
    [self.notesTableView reloadData];
    
    [self addEditButtons];
}

- (void)setOrderItem:(OrderItem *)orderItem{
    _orderItem = orderItem;
    [self itemInfoChanged:NO];
}

- (void)addEditButtons{
    [self.lessButton addTarget:self action:@selector(lessButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    self.lessButton.backgroundColor = [UIColor colorWithRed:209./255 green:209./255 blue:209./255 alpha:1.];
    [self.lessButton setTitle:@"-" forState:UIControlStateNormal];
    
    [self.moreButton addTarget:self action:@selector(moreButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    self.moreButton.backgroundColor = [UIColor redColor];
    [self.moreButton setTitle:@"+" forState:UIControlStateNormal];
}

// Called after every update of promos
- (void)itemInfoChanged:(BOOL)animated {
    if([_orderItem.errors count] > 0){
        self.additionalInfoMarkView.backgroundColor = [UIColor orangeColor];
        self.infoImageView.image = [UIImage imageNamed:@"exclamation.png"];
        [self.additionalInfoMarkView db_startObservingAnimationNotification];
    } else {
        self.additionalInfoMarkView.backgroundColor = [UIColor db_blueColor];
        self.infoImageView.image = [UIImage imageNamed:@"star.png"];
        [self.additionalInfoMarkView db_stopObservingAnimationNotification];
    }
    
    self.notesTableViewHeightConstraint.constant = [_orderItem.messages count] * 50;
    [self.contentView layoutIfNeeded];
    
    [self.notesTableView reloadData];
    if([_orderItem shouldShowAdditionalInfo] > 0){
        [self showAdditionalInfoMarkView:animated];
    } else {
        [self hideAdditionalInfoMarkView:animated];
    }
}

// Detect if user see mark on the left side of order item and hide/show it
- (void)showOrHideAdditionalInfo{
    if ([self.orderItem.messages count] == 0) {
        return;
    }
    
    if(!self.notesOpened && [self.orderItem.messages count] > 0){
        [self showAdditionalInfo];
    } else {
        [self hideAdditionalInfo];
    }
}

// Shows details tableView under order item
- (void)showAdditionalInfo{
    if([self.delegate respondsToSelector:@selector(orderItemCell:newPreferedHeight:)]){
        [self.delegate orderItemCell:self newPreferedHeight:self.itemCellContentView.frame.size.height + self.notesTableView.frame.size.height];
        self.notesOpened = YES;
    }
}

// Hides details tableView under order item
- (void)hideAdditionalInfo{
    if([self.delegate respondsToSelector:@selector(orderItemCell:newPreferedHeight:)]){
        [self.delegate orderItemCell:self newPreferedHeight:self.itemCellContentView.frame.size.height];
        self.notesOpened = NO;
    }
}

// Shows star/exclamation on the left side of order item
- (void)showAdditionalInfoMarkView:(BOOL)animated{
    self.itemCellContentViewOffset = self.additionalInfoMarkView.frame.size.width;
    self.leadingSpaceContentViewConstraint.constant = -(self.trailingSpaceContentViewConstraint.constant - self.itemCellContentViewOffset);
    self.leadingSpaceItemTitleConstraint.constant = 10;
    
    self.additionalInfoMarkView.hidden = NO;
    [UIView animateWithDuration:animated?0.25:0 animations:^{
        [self.itemCellContentView layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.contentView bringSubviewToFront:self.additionalInfoMarkView];
        if(self.notesOpened){
            [self showAdditionalInfo];
        }
    }];
}


// Hides star/exclamation on the left side of order item
- (void)hideAdditionalInfoMarkView:(BOOL)animated{
    self.itemCellContentViewOffset = 0;
    self.leadingSpaceContentViewConstraint.constant = -(self.trailingSpaceContentViewConstraint.constant - self.itemCellContentViewOffset);
    self.leadingSpaceItemTitleConstraint.constant = 20;
    [self.contentView sendSubviewToBack:self.additionalInfoMarkView];
    [self.contentView sendSubviewToBack:self.notesTableView];
    
    [UIView animateWithDuration:animated?0.25:0 animations:^{
        [self.itemCellContentView layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.additionalInfoMarkView.hidden = YES;
    }];
    
    [self hideAdditionalInfo];
}

- (void)additionalInfoButtonTapped:(id)sender{
    [self showOrHideAdditionalInfo];
    
    if([self.delegate respondsToSelector:@selector(orderItemCellReloadHeight:)]){
        [self.delegate orderItemCellReloadHeight:self];
    }
    
    [GANHelper analyzeEvent:@"item_additional_info_click" category:@"Order_screen"];
}

- (void)moveContentToOriginal{
    self.leadingSpaceContentViewConstraint.constant = self.itemCellContentViewOffset;
    self.trailingSpaceContentViewConstraint.constant = 0;
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.itemCellContentView layoutIfNeeded];
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
                         [self.itemCellContentView layoutIfNeeded];
                     } completion:nil];
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    if([self.delegate orderItemCellCanEdit:self]){
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
                    [self.delegate orderItemCellSwipe:self];
            }];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (IBAction)moreButtonTouchUpInside:(id)sender{
    if([self.delegate respondsToSelector:@selector(orderItemCellIncreaseItemCount:)]){
        [self.delegate orderItemCellIncreaseItemCount:self];
    }
}

- (IBAction)lessButtonTouchUpInside:(id)sender{
    if([self.delegate respondsToSelector:@selector(orderItemCellDecreaseItemCount:)]){
        [self.delegate orderItemCellDecreaseItemCount:self];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    CGPoint point = [touch locationInView:self.contentView];
    
    NSString *eventLabel = [NSString stringWithFormat:@"%@;%@", self.itemTitleLabel.text, self.itemQuantityLabel.text];
    
    if(CGRectContainsPoint(self.itemTitleLabel.frame, point)){
        [GANHelper analyzeEvent:@"item_title_click" label:eventLabel category:@"Order_screen"];
    }
    
    if(CGRectContainsPoint(self.itemQuantityLabel.frame, point)){
        [GANHelper analyzeEvent:@"item_count_click" label:eventLabel category:@"Order_screen"];
    }
    
    return YES;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_orderItem.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DBOrderItemNotesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBOrderItemNotesCell"];
    if(!cell){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DBOrderItemNotesCell" owner:self options:nil] firstObject];
    }
    
    cell.itemDescriptionLabel.text = _orderItem.messages[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [GANHelper analyzeEvent:@"item_additional_info_item_click" category:@"Order_screen"];
}

@end
