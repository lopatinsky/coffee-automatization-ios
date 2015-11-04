//
//  DBPositionModifiersListView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBPositionModifiersListModalView.h"
#import "DBPositionModifiersList.h"
#import "DBPositionModifierCell.h"
#import "DBPositionModifierPicker.h"
#import "DBPositionPriceView.h"
#import "DBMenuPosition.h"
#import "DBMenuPositionModifier.h"

#import "OrderCoordinator.h"

#import "UIView+RoundedCorners.h"

@interface DBPositionModifiersListModalView ()<DBPositionModifierPickerDelegate, DBPositionModifiersListDelegate>
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *totalTitleLabel;
@property (weak, nonatomic) IBOutlet DBPositionPriceView *totalPriceView;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@property (weak, nonatomic) IBOutlet UIView *modifiersListContainer;
@property (strong, nonatomic) DBPositionModifiersList *modifiersListView;

@property (strong, nonatomic) DBPositionModifierPicker *modifierPicker;

@property (strong, nonatomic) DBMenuPosition *position;
@end

@implementation DBPositionModifiersListModalView

- (instancetype)init{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBPositionModifiersListModalView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    self.totalPriceView.mode = DBPositionPriceViewModeInteracted;
    
    self.totalPriceView.touchAction = ^void(){
        [self.totalPriceView animatePositionAdditionWithCompletion:^{
            [[OrderCoordinator sharedInstance].itemsManager addPosition:self.position];
            
            [self hide];
        }];
    };
    
    self.modifiersListView = [DBPositionModifiersList new];
    self.modifiersListView.delegate = self;
    [self.modifiersListContainer addSubview:self.modifiersListView];
    self.modifiersListView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.modifiersListView alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self.modifiersListContainer];
    
    self.modifierPicker = [DBPositionModifierPicker new];
    self.modifierPicker.delegate = self;
    
    self.separatorView.backgroundColor = [UIColor db_defaultColor];
    
}

- (void)configureWithMenuPosition:(DBMenuPosition *)position {
    _position = position;
    
    [self.modifiersListView configureWithPosition:_position];
    
    [self adoptFrame];
    [self reload];
}

- (void)reload {
    self.totalPriceView.title = [NSString stringWithFormat:@"%.0f %@", self.position.actualPrice, [Compatibility currencySymbol]];
    
    [self.modifiersListView reload];
}

- (void)adoptFrame {
    int height = [[UIScreen mainScreen] bounds].size.height / 2;
    if(height < 300)
        height = 300;
    
    CGRect rect = self.frame;
    rect.size.height = height;
    self.frame = rect;
}

#pragma mark - DBPositionModifiersListDelegate

- (void)db_positionModifiersList:(DBPositionModifiersList *)list didSelectGroupModifier:(DBMenuPositionModifier *)modifier {
    [self.modifierPicker configureWithGroupModifier:modifier];
    [GANHelper analyzeEvent:@"group_modifier_show"
                      label:modifier.modifierId
                   category:MENU_SCREEN];

    [self.modifierPicker showOnView:self appearance:DBPopupAppearancePush];

}

- (void)db_positionModifiersListDidSelectSingleModifiers:(DBPositionModifiersList *)list {
    [self.modifierPicker configureWithSingleModifiers:self.position.singleModifiers];
    [self.modifierPicker showOnView:self appearance:DBPopupAppearancePush];
}


#pragma mark - DBPositionModifierPickerDelegate

- (void)db_positionModifierPickerDidChangeItemCount:(DBPositionModifierPicker *)picker{
    [self reload];
}

- (void)db_positionModifierPicker:(DBPositionModifierPicker *)picker didSelectNewItem:(DBMenuPositionModifierItem *)item{
    [self reload];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.modifierPicker hide];
    });
}

@end
