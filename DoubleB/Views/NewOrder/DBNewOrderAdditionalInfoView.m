//
//  DBNewOrderAdditionalInfoView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 20.03.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBNewOrderAdditionalInfoView.h"
#import "OrderManager.h"
#import "DBDiscountMessageCell.h"

@interface DBNewOrderAdditionalInfoView()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;

@property (strong, nonatomic) NSArray *messages;
@property (nonatomic) BOOL currentlyShowPromos;
@end

@implementation DBNewOrderAdditionalInfoView

- (void)awakeFromNib{
    self.tableView.scrollEnabled = NO;
    self.tableView.backgroundColor = [UIColor db_backgroundColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)showPromos:(NSArray *)promos completion:(void(^)())completion{
    [self showPromos:promos animation:nil completion:completion];
}

- (void)showPromos:(NSArray *)promos animation:(void(^)())animation completion:(void(^)())completion{
    self.messages = promos;
    self.currentlyShowPromos = YES;
    
    if(self.messages && [self.messages count] > 0){
        [self.tableView reloadData];
        [self show:animation completion:completion];
    }
}

- (void)showErrors:(NSArray *)errors completion:(void(^)())completion{
    [self showErrors:errors animation:nil completion:completion];
}

- (void)showErrors:(NSArray *)errors animation:(void(^)())animation completion:(void(^)())completion{
    self.messages = errors;
    self.currentlyShowPromos = NO;
    
    if(self.messages && [self.messages count] > 0){
        [self.tableView reloadData];
        [self show:animation completion:completion];
    }
}

- (void)show:(void(^)())animation completion:(void(^)())completion{
    int errorViewHeight = 44 * [self.messages count];
    
    self.hidden = NO;
    if(animation){
        [UIView animateWithDuration:.2f animations:^{
            self.heightConstraint.constant = errorViewHeight;
            animation();
        } completion:^(BOOL finished) {
            if(completion)
                completion();
        }];
    } else {
        self.heightConstraint.constant = errorViewHeight;
        [self layoutIfNeeded];
        
        if(completion)
            completion();
    }
}

- (void)hide:(void(^)())animation completion:(void(^)())completion{
    if(animation){
        [UIView animateWithDuration:.2f animations:^{
            self.heightConstraint.constant = 0;
            animation();
        } completion:^(BOOL finished) {
            self.hidden = YES;
            if(completion)
                completion();
        }];
    } else {
        self.heightConstraint.constant = 0;
        [self layoutIfNeeded];
        self.hidden = YES;
        if(completion)
            completion();
    }
}

#pragma mark UITableViewDelegate

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBDiscountMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBDiscountMessageCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DBDiscountMessageCell" owner:self options:nil] firstObject];
    }
    
    cell.messageLabel.text = self.messages[indexPath.row];
    
    if (self.currentlyShowPromos) {
        cell.messageLabel.textColor = [UIColor db_defaultColor];
        cell.messageLabel.textAlignment = NSTextAlignmentRight;
    } else {
        cell.messageLabel.textColor = [UIColor orangeColor];
        cell.messageLabel.textAlignment = NSTextAlignmentLeft;
        [cell.messageLabel db_startObservingAnimationNotification];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

@end
