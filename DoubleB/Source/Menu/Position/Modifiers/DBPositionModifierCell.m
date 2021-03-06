//
//  DBPositionModifierCell.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 03.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBPositionModifierCell.h"
#import "DBMenuPositionModifier.h"
#import "DBMenuPositionModifierItem.h"

@interface DBPositionModifierCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *choiceLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@property (strong, nonatomic) DBMenuPositionModifier *groupModifier;
@property (strong, nonatomic) NSArray *singleModifiers;

@end

@implementation DBPositionModifierCell

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBPositionModifierCell" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.arrowImageView templateImageWithName:@"right_arrow_icon" tintColor:[UIColor blackColor]];
    self.separatorView.backgroundColor = [UIColor db_separatorColor];
    
    self.titleLabel.textColor = [UIColor db_defaultColor];
    self.choiceLabel.textColor = [UIColor colorWithWhite:0.f alpha:0.7f];
    self.priceLabel.textColor = [UIColor db_defaultColor];
}

- (void)configureWithGroupModifier:(DBMenuPositionModifier *)modifier {
    _groupModifier = modifier;
    
    self.titleLabel.text = modifier.modifierName;

    self.choiceLabel.text = @"";
    self.priceLabel.text = @"";
    
    if(modifier.selectedItem){
        self.choiceLabel.text = modifier.selectedItem.itemName;
        if(modifier.actualPrice > 0){
            self.priceLabel.text = [NSString stringWithFormat:@"+%.0f %@", modifier.actualPrice, [Compatibility currencySymbol]];
        }
    } else {
        if(!modifier.required) {
            self.choiceLabel.text = NSLocalizedString(@"Не выбирать ничего", nil);
        }
    }
}

- (void)configureWithSingleModifiers:(NSArray *)singleModifiers {
    _singleModifiers = singleModifiers;
    
    self.titleLabel.text = NSLocalizedString(@"Добавки", nil);
    
    self.choiceLabel.text = NSLocalizedString(@"Не выбирать ничего", nil);
    self.priceLabel.text = @"";
    
    NSMutableString *modifiersString =[[NSMutableString alloc] init];
    
    double total = 0;
    for(DBMenuPositionModifier *modifier in singleModifiers){
        if(modifier.selectedCount > 0){
            [modifiersString appendString:[NSString stringWithFormat:@"%@ (x%ld)  ", modifier.modifierName, (long)modifier.selectedCount]];
            total += modifier.actualPrice;
        }
    }
    
    if (modifiersString.length > 0)
        self.choiceLabel.text = modifiersString;
    if (total > 0)
        self.priceLabel.text = [NSString stringWithFormat:@"+%.0f %@", total, [Compatibility currencySymbol]];
}

@end
