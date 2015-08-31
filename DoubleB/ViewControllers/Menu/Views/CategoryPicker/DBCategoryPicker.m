//
//  DBCategoryPicker.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 02.04.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBCategoryPicker.h"
#import "DBCategoryPickerCell.h"
#import "DBMenuCategory.h"

@interface DBCategoryPicker ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) DBMenuCategory *selectedCategory;

@end

@implementation DBCategoryPicker

- (instancetype)init{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBCategoryPicker" owner:self options:nil] firstObject];
    
    [self commonInit];
    
    return self;
}

- (void)commonInit{
    self.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 40.f;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.separatorView.backgroundColor = [UIColor db_defaultColor];
}

- (void)configureWithCurrentCategory:(DBMenuCategory *)category categories:(NSArray *)categories{
    self.categories = categories;
    self.selectedCategory = category;
    
    [self.tableView reloadData];
    
    [self configureSize];
}

- (void)configureSize{
    CGRect rect = self.frame;
    rect.size.height = self.tableView.contentSize.height;
    
    if(rect.size.height > 300){
        rect.size.height = 300;
        self.tableView.scrollEnabled = YES;
    } else {
        self.tableView.scrollEnabled = NO;
    }
    
    self.frame = rect;
}

- (void)openedOnView:(UIView *)view{
    _isOpened = YES;
    _owner = view;
}

- (void)closed{
    _isOpened = NO;
    _owner = nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.categories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DBCategoryPickerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBCategoryPickerCell"];
    if(!cell){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DBCategoryPickerCell" owner:self options:nil] firstObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    DBMenuCategory *category = self.categories[indexPath.row];
    cell.categoryLabel.text = category.name;
    
    if(self.selectedCategory == category){
        cell.categoryLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.f];
    } else {
        cell.categoryLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.f];
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DBMenuCategory *category = self.categories[indexPath.row];
    
    if([self.delegate respondsToSelector:@selector(db_categoryPicker:didSelectCategory:)]){
        [self.delegate db_categoryPicker:self didSelectCategory:category];
    }
}

@end
