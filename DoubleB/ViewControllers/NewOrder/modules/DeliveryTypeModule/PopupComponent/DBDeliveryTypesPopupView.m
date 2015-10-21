//
//  DBDeliveryTypesPopupView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 20/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBDeliveryTypesPopupView.h"
#import "DBDeliveryTypeCell.h"

#import "DBCompanyInfo.h"
#import "OrderCoordinator.h"

@interface DBDeliveryTypesPopupView ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSArray *deliveryTypes;

@property (strong, nonatomic) UIView *holder;
@property (strong, nonatomic) UIImageView *placeholderView;

@end

@implementation DBDeliveryTypesPopupView

- (instancetype)init {
    self = [super init];
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.tableView = [UITableView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.rowHeight = 45.f;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.tableView];
    [self.tableView alignTop:@"0" leading:@"0" bottom:@"0" trailing:@"0" toView:self];
    
    return self;
}

- (void)config {
    NSMutableArray *types = [[NSMutableArray alloc] initWithArray:[DBCompanyInfo sharedInstance].deliveryTypes];
    DBDeliveryType *selectedType = [[DBCompanyInfo sharedInstance] deliveryTypeById:[OrderCoordinator sharedInstance].deliverySettings.deliveryType.typeId];
    [types removeObject:selectedType];
    [types insertObject:selectedType atIndex:0];
    
    self.deliveryTypes = types;
    
    [self.tableView reloadData];
}

- (void)showFrom:(UIView *)fromView onView:(UIView *)parentView {
    [self config];
    
    self.parentView = parentView;
    [self configOverlay];
    
    CGRect rect = [parentView convertRect:fromView.frame fromView:fromView.superview];
    
    _holder = [UIView new];
    _holder.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, [self contentHeight]);
    _holder.backgroundColor = [UIColor clearColor];
    _holder.clipsToBounds = YES;
    
    CGRect selfRect = self.frame;
    selfRect.origin.y = -[self contentHeight];
    selfRect.origin.x = 0;
    selfRect.size = _holder.frame.size;
    self.frame = selfRect;
    
    [_holder addSubview:self];
    
    _placeholderView = [[UIImageView alloc] initWithFrame:fromView.bounds];
    _placeholderView.image = [fromView snapshotImage];
    [_holder addSubview:_placeholderView];
    
    [self.parentView addSubview:_holder];
    
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = self.frame;
        rect.origin.y = 0;
        self.frame = rect;
        
        self.overlayView.alpha = 1;
    } completion:^(BOOL finished) {
        [_placeholderView removeFromSuperview];
    }];
}

- (void)hide {
    double time = 0.2;
    
    [UIView animateWithDuration:time animations:^{
        CGRect rect = self.frame;
        rect.origin.y = -[self contentHeight];
        self.frame = rect;
        
        self.overlayView.alpha = 0;
        self.holder.alpha = 0;
    } completion:^(BOOL f){
        [self.holder removeFromSuperview];
        [self.overlayView removeFromSuperview];
    }];
}

- (CGFloat)contentHeight {
    return self.tableView.rowHeight * [self.tableView numberOfRowsInSection:0];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.deliveryTypes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBDeliveryTypeCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"DBDeliveryTypeCell"];
        
    if (!cell) {
        cell = [[DBDeliveryTypeCell alloc] init];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    DBDeliveryType *type = self.deliveryTypes[indexPath.row];
    [cell configureWithDeliveryType:type];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DBDeliveryTypeCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    [[OrderCoordinator sharedInstance].deliverySettings selectDeliveryType:cell.deliveryType];
    [self.tableView reloadData];
    [self hide];
}

@end
