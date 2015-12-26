//
//  DBMenuModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 25/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBMenuModuleView.h"

@implementation DBMenuModuleView

- (void)reloadContent {
}

@end

@implementation DBMenuTableModuleView

- (void)commonInit {
    [super commonInit];
    
    self.tableView = [UITableView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [UIView new];
    
    [self addSubview:self.tableView];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self];
}

- (void)setTableHeaderModuleView:(DBModuleView *)tableHeaderModuleView {
    _tableHeaderModuleView = tableHeaderModuleView;
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, _tableHeaderModuleView.frame.size.height)];
    [header addSubview:_tableHeaderModuleView];
    _tableHeaderModuleView.translatesAutoresizingMaskIntoConstraints = NO;
    [_tableHeaderModuleView alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:header];
    self.tableView.tableHeaderView = header;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}


@end