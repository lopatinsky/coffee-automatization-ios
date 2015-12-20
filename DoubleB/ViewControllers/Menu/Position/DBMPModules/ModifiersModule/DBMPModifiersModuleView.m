//
//  DBMPModifiersModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 19/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBMPModifiersModuleView.h"
#import "DBMPModifiersChoiceCell.h"
#import "DBPositionModifiersList.h"

#import "DBMenuPosition.h"
#import "DBMenuPositionModifier.h"
#import "DBMenuPositionModifierItem.h"

@interface DBMPModifiersModuleView ()<UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *modifiersListContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintModifiersListContainerHeight;

@property (strong, nonatomic) DBPositionModifiersList *modifiersList;

@property (strong, nonatomic) NSMutableArray *selectedTitles;
@property (strong, nonatomic) NSMutableArray *selectedPrices;


@end

@implementation DBMPModifiersModuleView

+ (DBMPModifiersModuleView *)create {
    DBMPModifiersModuleView *view = [[[NSBundle mainBundle] loadNibNamed:@"DBMPModifiersModuleView" owner:self options:nil] firstObject];
    
    return view;
}

- (void)awakeFromNib {
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 30.f;
    self.modifiersList = [DBPositionModifiersList new];
    [self.modifiersListContainer addSubview:self.modifiersList];
    self.modifiersList.translatesAutoresizingMaskIntoConstraints = NO;
    [self.modifiersList alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self];
    
    self.selectedTitles = [NSMutableArray new];
    self.selectedPrices = [NSMutableArray new];
}

- (void)setPosition:(DBMenuPosition *)position {
    _position = position;
    
    [self reload:NO];
}

- (void)reload:(BOOL)animated {
    self.constraintModifiersListContainerHeight.constant = self.modifiersList.contentHeight;
    
    for(DBMenuPositionModifier *modifier in self.position.groupModifiers){
        if(modifier.selectedItem){
                [self.selectedTitles addObject:[NSString stringWithFormat:@"%@ - %@ (%@)\n", [Compatibility currencySymbol], modifier.selectedItem.itemName, modifier.modifierName]];
        }
    }
    
    for(DBMenuPositionModifier *modifier in self.position.singleModifiers){
        if(modifier.selectedCount > 0){
            if(modifier.actualPrice > 0){
                [modifiersString appendString:[NSString stringWithFormat:@"+%.0f %@ - %@ (x%ld)\n", modifier.actualPrice, [Compatibility currencySymbol], modifier.modifierName, (long)modifier.selectedCount]];
            } else {
                [modifiersString appendString:[NSString stringWithFormat:@"%@ (x%ld)\n", modifier.modifierName, (long)modifier.selectedCount]];
            }
        }
    }
}

- (CGFloat)moduleViewContentHeight {
    return self.tableView.contentSize.height + self.modifiersList.contentHeight;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBMPModifiersChoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBMPModifiersChoiceCell"];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DBMPModifiersChoiceCell" owner:self options:nil] firstObject];
    }
    
    
}

@end
