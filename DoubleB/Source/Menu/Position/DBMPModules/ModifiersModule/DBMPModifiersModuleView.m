//
//  DBMPModifiersModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 19/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBMPModifiersModuleView.h"
#import "DBModulesViewController.h"
#import "DBPositionModifierPicker.h"
#import "DBPositionModifiersList.h"

#import "DBMenuPosition.h"
#import "DBMenuPositionModifier.h"
#import "DBMenuPositionModifierItem.h"

@interface DBMPModifiersModuleView () <DBPositionModifierPickerDelegate, DBPositionModifiersListDelegate, DBPopupComponentDelegate>
@property (strong, nonatomic) DBPositionModifiersList *modifiersList;
@property (strong, nonatomic) DBPositionModifierPicker *modifierPicker;

@end

@implementation DBMPModifiersModuleView

+ (DBMPModifiersModuleView *)create {
    return [DBMPModifiersModuleView new];
}

- (void)commonInit {
    self.modifiersList = [DBPositionModifiersList new];
    self.modifiersList.scrollEnabled = NO;
    self.modifiersList.delegate = self;
    [self addSubview:self.modifiersList];
    self.modifiersList.translatesAutoresizingMaskIntoConstraints = NO;
    [self.modifiersList alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self];
    
    self.modifierPicker = [DBPositionModifierPicker new];
    self.modifierPicker.modifierDelegate = self;
    self.modifierPicker.delegate = self;
}

- (void)setPosition:(DBMenuPosition *)position {
    _position = position;
    
    [self.modifiersList configureWithPosition:self.position];
    
    [self reload:NO];
}

- (void)reload:(BOOL)animated {
    [super reload:animated];
    
    [self.modifiersList reload];
}

- (CGFloat)moduleViewContentHeight {
    return self.modifiersList.contentHeight;
}


#pragma mark - DBPositionModifiersListDelegate

- (void)db_positionModifiersList:(DBPositionModifiersList *)list didSelectGroupModifier:(DBMenuPositionModifier *)modifier {
    [self.modifierPicker configureWithGroupModifier:modifier];
    self.modifierPicker.currencyDisplayMode = (self.position.mode == DBMenuPositionModeBonus) ? DBUICurrencyDisplayModeNone : DBUICurrencyDisplayModeRub;
    
    UIViewController *container = self.ownerViewController.navigationController;
    if (!container) {
        container = self.ownerViewController;
    }
    [self.modifierPicker showOnView:container.view appearance:DBPopupAppearanceModal transition:DBPopupTransitionBottom];
    
    [GANHelper analyzeEvent:@"group_modifier_show"
                      label:modifier.modifierId
                   category:PRODUCT_SCREEN];
}

- (void)db_positionModifiersListDidSelectSingleModifiers:(DBPositionModifiersList *)list {
    [self.modifierPicker configureWithSingleModifiers:self.position.singleModifiers];
    self.modifierPicker.currencyDisplayMode = (self.position.mode == DBMenuPositionModeBonus) ? DBUICurrencyDisplayModeNone : DBUICurrencyDisplayModeRub;
    
    UIViewController *container = self.ownerViewController.navigationController;
    if (!container) {
        container = self.ownerViewController;
    }
    [self.modifierPicker showOnView:container.view appearance:DBPopupAppearanceModal transition:DBPopupTransitionBottom];
}

#pragma mark - DBPositionModifierPickerDelegate

- (void)db_positionModifierPickerDidChangeItemCount:(DBPositionModifierPicker *)picker{
    [self.modifiersList reload];
    
    [((DBModulesViewController *)self.ownerViewController) reloadModules:YES];
}

- (void)db_positionModifierPicker:(DBPositionModifierPicker *)picker didSelectNewItem:(DBMenuPositionModifierItem *)item{
    [self.modifiersList reload];
    [((DBModulesViewController *)self.ownerViewController) reloadModules:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.modifierPicker hide];
    });
}

@end
