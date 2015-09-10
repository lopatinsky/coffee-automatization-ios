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
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) DBMenuPositionModifier *modifier;
@property (strong, nonatomic) NSArray *singleModifiers;

@property (nonatomic) BOOL havePrice;

@end

@implementation DBPositionModifierPicker

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBPositionModifierPicker" owner:self options:nil] firstObject];
    
    [self commonInit];
    
    return self;
}

- (void)commonInit {
    self.separatorView.backgroundColor = [UIColor db_separatorColor];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 45.f;
    self.tableView.tableFooterView = [UIView new];
    
    [self.doneButton setTitleColor:[UIColor db_defaultColor] forState:UIControlStateNormal];
    [self.doneButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
}

- (void)adoptFrame {
    int height = [[UIScreen mainScreen] bounds].size.height / 2;
    if(height < 300)
        height = 300;
    
    CGRect rect = self.frame;
    rect.size.height = height;
    self.frame = rect;
}

- (void)configureWithGroupModifier:(DBMenuPositionModifier *)modifier {
    self.modifier = modifier;
    _type = DBPositionModifierPickerTypeGroup;
    
    self.havePrice = NO;
    for (DBMenuPositionModifierItem *item in self.modifier.items){
        self.havePrice = self.havePrice || item.itemPrice > 0;
    }
    
    self.modifierTitleLabel.text = self.modifier.modifierName;
    self.additionalInfoLabel.text = [NSString stringWithFormat:@"(%@)", NSLocalizedString(@"Можно выбрать один вариант", nil)];
    
    [self.tableView reloadData];
    [self adoptFrame];
}
 
- (void)configureWithSingleModifiers:(NSArray *)modifiers {
    self.singleModifiers = modifiers;
    _type = DBPositionModifierPickerTypeSingle;
    
    self.havePrice = NO;
    for (DBMenuPositionModifier *singModifier in self.singleModifiers) {
        self.havePrice = self.havePrice || singModifier.modifierPrice > 0;
    }
    
    self.modifierTitleLabel.text = NSLocalizedString(@"Добавки", nil);
    self.additionalInfoLabel.text = [NSString stringWithFormat:@"(%@)", NSLocalizedString(@"Можно выбрать несколько", nil)];
    
    [self.tableView reloadData];
    [self adoptFrame];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.type == DBPositionModifierPickerTypeGroup) {
        NSInteger shift = self.modifier.required ? 0 : 1;
        return [self.modifier.items count] + shift;
    } else {
        return [self.singleModifiers count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.type == DBPositionModifierPickerTypeGroup) {
        DBPositionGroupModifierItemCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"DBPositionGroupModifierItemCell"];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DBPositionGroupModifierItemCell" owner:self options:nil] firstObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        NSInteger shift = self.modifier.required ? 0 : 1;
        if (indexPath.row == 0 && shift == 1) {
            [cell configureWithModifierItem:nil havePrice:NO];
            [cell select:(self.modifier.selectedItem == nil) animated:NO];
        } else {
            DBMenuPositionModifierItem *item = self.modifier.items[indexPath.row - shift];
            [cell configureWithModifierItem:item havePrice:self.havePrice];
            [cell select:[self.modifier.selectedItem isEqual:item] animated:NO];
        }
        cell.currencyDisplayMode = self.currencyDisplayMode;
        
        return cell;
    } else {
        DBPositionSingleModifierCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"DBPositionSingleModifierCell"];
        if(!cell){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DBPositionSingleModifierCell" owner:self options:nil] firstObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        [cell configureWithModifier:self.singleModifiers[indexPath.row] havePrice:self.havePrice delegate:self];
        cell.currencyDisplayMode = self.currencyDisplayMode;
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.type == DBPositionModifierPickerTypeGroup){
        NSInteger shift = self.modifier.required ? 0 : 1;
        if(indexPath.row == 0 && shift == 1){
            [self.modifier clearSelectedItem];
        } else {
            [self.modifier selectItemAtIndex:indexPath.row - shift];
        }
        
        for(int i = 0; i < [tableView numberOfRowsInSection:indexPath.section]; i++){
            DBPositionGroupModifierItemCell *cell = (DBPositionGroupModifierItemCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
            BOOL select = [cell.item isEqual:self.modifier.selectedItem] || (!self.modifier.selectedItem && !cell.item);
            [cell select:select animated:YES];
        }
        
        if([self.delegate respondsToSelector:@selector(db_positionModifierPicker:didSelectNewItem:)]){
            [self.delegate db_positionModifierPicker:self didSelectNewItem:self.modifier.selectedItem];
        }
        
        [GANHelper analyzeEvent:@"modifier_selected"
                          label:self.modifier.selectedItem.itemId
                       category:GROUP_MODIFIER_PICKER];
    }
}

#pragma mark - DBPositionSingleModifierCellDelegate

- (void)db_singleModifierCellDidIncreaseModifierItemCount:(DBMenuPositionModifier *)modifier{
    if([self.delegate respondsToSelector:@selector(db_positionModifierPickerDidChangeItemCount:)]){
        [self.delegate db_positionModifierPickerDidChangeItemCount:self];
    }
    
    [GANHelper analyzeEvent:@"product_single_modifier_plus" label:modifier.modifierId category:SINGLE_MODIFIER_PICKER];
}

- (void)db_singleModifierCellDidDecreaseModifierItemCount:(DBMenuPositionModifier *)modifier{
    if([self.delegate respondsToSelector:@selector(db_positionModifierPickerDidChangeItemCount:)]){
        [self.delegate db_positionModifierPickerDidChangeItemCount:self];
    }
    
    [GANHelper analyzeEvent:@"product_single_modifier_minus" label:modifier.modifierId category:SINGLE_MODIFIER_PICKER];
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if(self.type == DBPositionModifierPickerTypeGroup){
        [GANHelper analyzeEvent:@"product_modifier_scroll" label:self.modifier.modifierId category:GROUP_MODIFIER_PICKER];
    } else {
        [GANHelper analyzeEvent:@"product_single_modifiers_scroll" category:SINGLE_MODIFIER_PICKER];
    }
}

@end
