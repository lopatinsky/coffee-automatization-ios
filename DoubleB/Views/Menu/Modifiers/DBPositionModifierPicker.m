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


@interface DBPositionModifierPicker ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UILabel *modifierTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *additionalInfoLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) DBMenuPositionModifier *modifier;
@property (strong, nonatomic) NSArray *singleModifiers;

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
    rect.size.height = self.titleView.frame.size.height + self.tableView.contentSize.height;
    self.frame = rect;
    
    [self layoutIfNeeded];
}

- (void)configureWithGroupModifier:(DBMenuPositionModifier *)modifier{
    self.modifier = modifier;
    _type = DBPositionModifierPickerTypeGroup;
    
    [self.tableView reloadData];
    [self adoptFrame];
}

- (void)configureWithSingleModifiers:(NSArray *)modifiers{
    self.singleModifiers = modifiers;
    _type = DBPositionModifierPickerTypeSingle;
    
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
    [self.overlayView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide:)]];
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
        return nil;
    } else {
        DBPositionSingleModifierCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"DBPositionSingleModifierCell"];
        if(!cell){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DBPositionSingleModifierCell" owner:self options:nil] firstObject];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        [cell configureWithModifier:self.singleModifiers[indexPath.row]];
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

@end
