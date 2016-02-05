//
//  DBPositionModifiersList.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 09/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBPositionModifiersList.h"
#import "DBPositionModifierCell.h"
#import "DBMenuPosition.h"
#import "DBMenuPositionModifier.h"

@interface DBPositionModifiersList ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) DBMenuPosition *position;

@end

@implementation DBPositionModifiersList

- (instancetype)init {
    self = [super init];
    
    [self commonInit];
    
    return self;
}

- (void)commonInit {
    self.tableView = [UITableView new];
    [self addSubview:self.tableView];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 55.f;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)configureWithPosition:(DBMenuPosition *)position{
    _position = position;
}

- (void)reload {
    [self.tableView reloadData];
}

- (NSInteger)contentHeight {
    NSInteger height = self.position.groupModifiers.count * self.tableView.rowHeight;
    height += self.position.singleModifiers.count > 0 ? self.tableView.rowHeight : 0;
    
    return height;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    _scrollEnabled = scrollEnabled;
    
    self.tableView.scrollEnabled = _scrollEnabled;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return [self.position.groupModifiers count];
    } else {
        return [self.position.singleModifiers count] > 0 ? 1 : 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DBPositionModifierCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBPositionModifierCell1"];
    if(!cell){
        cell = [DBPositionModifierCell new];
    }
    
    if(indexPath.section == 0){
        [cell configureWithGroupModifier:self.position.groupModifiers[indexPath.row]];
    } else {
        [cell configureWithSingleModifiers:self.position.singleModifiers];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        if([self.delegate respondsToSelector:@selector(db_positionModifiersList:didSelectGroupModifier:)]){
            [self.delegate db_positionModifiersList:self didSelectGroupModifier:self.position.groupModifiers[indexPath.row]];
        }
    } else {
        if([self.delegate respondsToSelector:@selector(db_positionModifiersListDidSelectSingleModifiers:)]){
            [self.delegate db_positionModifiersListDidSelectSingleModifiers:self];
        }
    }
}

@end
