//
//  DBPositionModifierPicker.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 03.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBPositionModifierPicker.h"
#import "DBMenuPosition.h"
#import "DBMenuPositionModifier.h"
#import "DBMenuPositionModifierItem.h"
#import "DBPositionSingleModifierCell.h"
#import "DBPositionGroupModifierItemCell.h"


@interface DBPositionModifierPicker ()<UITableViewDataSource, UITableViewDelegate, DBPositionSingleModifierCellDelegate>
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UILabel *modifierTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *additionalInfoLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) DBMenuPositionModifier *modifier;
@property (strong, nonatomic) NSArray *singleModifiers;

@property (nonatomic) BOOL havePrice;

@property (strong, nonatomic) UIView *parentView;
@property (strong, nonatomic) UIImageView *overlayView;

@end

@implementation DBPositionModifierPicker

- (instancetype)init{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBPositionModifierPicker" owner:self options:nil] firstObject];
    
    [self commonInit];
    
    return self;
}

- (void)commonInit{
    self.separatorView.backgroundColor = [UIColor db_separatorColor];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 45.f;
}

- (void)adoptFrame{
    CGRect rect = self.frame;
    rect.size.height = self.titleView.frame.size.height + self.tableView.contentSize.height + 5;
    self.frame = rect;
    
    [self layoutIfNeeded];
}

- (void)configureWithGroupModifier:(DBMenuPositionModifier *)modifier{
    self.modifier = modifier;
    _type = DBPositionModifierPickerTypeGroup;
    
    self.havePrice = NO;
    for(DBMenuPositionModifierItem *item in modifier.items){
        self.havePrice = self.havePrice || item.itemPrice > 0;
    }
    
    self.modifierTitleLabel.text = self.modifier.modifierName;
    self.additionalInfoLabel.text = [NSString stringWithFormat:@"(%@)", NSLocalizedString(@"Можно выбрать один вариант", nil)];
    
    [self.tableView reloadData];
    [self adoptFrame];
}

- (void)configureWithSingleModifiers:(NSArray *)modifiers{
    self.singleModifiers = modifiers;
    _type = DBPositionModifierPickerTypeSingle;
    
    self.havePrice = NO;
    for(DBMenuPositionModifier *singModifier in modifiers){
        self.havePrice = self.havePrice || singModifier.modifierPrice > 0;
    }
    
    self.modifierTitleLabel.text = NSLocalizedString(@"Добавки", nil);
    self.additionalInfoLabel.text = [NSString stringWithFormat:@"(%@)", NSLocalizedString(@"Можно выбрать несколько", nil)];
    
    [self.tableView reloadData];
    [self adoptFrame];
}

- (void)showOnView:(UIView *)parentView{
    self.parentView = parentView;
    
    UIImage *snapshot = [parentView snapshotImage];
    self.overlayView = [[UIImageView alloc] initWithFrame:parentView.bounds];
    self.overlayView.image = [snapshot applyBlurWithRadius:5 tintColor:[UIColor colorWithWhite:0.3 alpha:0.6] saturationDeltaFactor:1.5 maskImage:nil];
    self.overlayView.alpha = 0;
    self.overlayView.userInteractionEnabled = YES;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide:)];
    recognizer.cancelsTouchesInView = NO;
    [self.overlayView addGestureRecognizer:recognizer];
    [parentView addSubview:self.overlayView];

    CGRect rect = self.frame;
    rect.origin.y = self.overlayView.bounds.size.height;
    rect.size.width = self.overlayView.bounds.size.width;
    self.frame = rect;

    [self.overlayView addSubview:self];

    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.frame;
        frame.origin.y -= self.bounds.size.height;
        self.frame = frame;
        
        self.overlayView.alpha = 1;
    }];
}

- (void)hide{
    [self hide:nil];
}

- (void)hide:(UITapGestureRecognizer *)sender{
    CGPoint touch = [sender locationInView:nil];
    
    if(!CGRectContainsPoint(self.frame, touch)){
        [UIView animateWithDuration:0.2 animations:^{
            self.overlayView.alpha = 0;
            CGRect rect = self.frame;
            rect.origin.y = self.parentView.bounds.size.height;
            self.frame = rect;
        } completion:^(BOOL f){
            [self removeFromSuperview];
            [self.overlayView removeFromSuperview];
        }];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.type == DBPositionModifierPickerTypeGroup){
        return [self.modifier.items count];
    } else {
        return [self.singleModifiers count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.type == DBPositionModifierPickerTypeGroup){
        DBPositionGroupModifierItemCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"DBPositionGroupModifierItemCell"];
        if(!cell){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DBPositionGroupModifierItemCell" owner:self options:nil] firstObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        DBMenuPositionModifierItem *item = self.modifier.items[indexPath.row];
        [cell configureWithModifierItem:item havePrice:self.havePrice];
        
        if([self.modifier.selectedItem isEqual:item]){
            [cell select:YES animated:NO];
        } else {
            [cell select:NO animated:NO];
        }
        
        return cell;
    } else {
        DBPositionSingleModifierCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"DBPositionSingleModifierCell"];
        if(!cell){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DBPositionSingleModifierCell" owner:self options:nil] firstObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        [cell configureWithModifier:self.singleModifiers[indexPath.row] havePrice:self.havePrice delegate:self];
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.type == DBPositionModifierPickerTypeGroup){
        [self.modifier selectItemAtIndex:indexPath.row];
        
        for(int i = 0; i < [self.modifier.items count]; i++){
            DBPositionGroupModifierItemCell *cell = (DBPositionGroupModifierItemCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if(i == indexPath.row){
                [cell select:YES animated:YES];
            } else {
                [cell select:NO animated:YES];
            }
        }
        
        DBMenuPositionModifierItem *item = [self.modifier.items objectAtIndex:indexPath.row];
        if([self.delegate respondsToSelector:@selector(db_positionModifierPicker:didSelectNewItem:)]){
            [self.delegate db_positionModifierPicker:self didSelectNewItem:item];
        }
    }
}

#pragma mark - DBPositionSingleModifierCellDelegate

- (void)db_singleModifierCellDidIncreaseModifierItemCount:(DBMenuPositionModifier *)modifier{
    if([self.delegate respondsToSelector:@selector(db_positionModifierPickerDidChangeItemCount:)]){
        [self.delegate db_positionModifierPickerDidChangeItemCount:self];
    }
}

- (void)db_singleModifierCellDidDecreaseModifierItemCount:(DBMenuPositionModifier *)modifier{
    if([self.delegate respondsToSelector:@selector(db_positionModifierPickerDidChangeItemCount:)]){
        [self.delegate db_positionModifierPickerDidChangeItemCount:self];
    }
}

@end
