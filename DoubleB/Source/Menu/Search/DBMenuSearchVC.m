//
//  DBMenuSearchVC.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 10/02/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBMenuSearchVC.h"
#import "DBMenuSearchBarView.h"
#import "DBSearchPositionTableCell.h"
#import "DBMenu.h"
#import "OrderCoordinator.h"
#import "DBPopupViewController.h"

@interface DBMenuSearchVC ()<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) DBMenuSearchBarView *searchView;
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSArray *searchResults;

@property (weak, nonatomic) UIViewController *container;

@end

@implementation DBMenuSearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.searchView = [DBMenuSearchBarView create];
    [self.searchView.cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.searchView.searchBar.delegate = self;
    [self.view addSubview:self.searchView];
    
    self.tableView = [UITableView new];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 50.f;
    self.tableView.backgroundColor = [UIColor colorWithRed:242./255 green:242./255 blue:242./255 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.searchView.searchBar becomeFirstResponder];
    
    [self showSearchView];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.searchView.searchBar resignFirstResponder];
    
    [self hideSearchView];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)presentInContainer:(UIViewController *)container {
    _container = container;
    
    [_container.view addSubview:self.view];
    [_container addChildViewController:self];
    [self beginAppearanceTransition:YES animated:YES];
    
    CGRect tableRect = self.tableView.frame;
    tableRect.size.width = _container.view.frame.size.width;
    tableRect.origin.y = self.searchView.frame.size.height;
    tableRect.size.height = _container.view.frame.size.height - tableRect.origin.y;
    self.tableView.frame = tableRect;
    
    self.tableView.alpha = 0;
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = self.searchView.frame;
        rect.origin.y = 0;
        self.searchView.frame = rect;
        
        self.tableView.alpha = 1;
    } completion:^(BOOL finished) {
        [self endAppearanceTransition];
    }];
}

- (void)hide {
    [self beginAppearanceTransition:NO animated:YES];
    [UIView animateWithDuration:0.2 animations:^{
        self.tableView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

- (void)showSearchView {
    CGRect searchViewRect = self.searchView.frame;
    searchViewRect.size.width = _container.view.frame.size.width;
    searchViewRect.origin.y = -searchViewRect.size.height;
    self.searchView.frame = searchViewRect;
    
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = self.searchView.frame;
        rect.origin.y = 0;
        self.searchView.frame = rect;
    } completion:^(BOOL finished) {
    }];
}

- (void)hideSearchView {
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = self.searchView.frame;
        rect.origin.y = -rect.size.height;
        self.searchView.frame = rect;
    } completion:^(BOOL finished) {
    }];
}

- (void)cancelButtonClick {
    [self hide];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.searchResults = [[DBMenu sharedInstance] filterPositions:searchText venue:[OrderCoordinator sharedInstance].orderManager.venue];
    
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchView.searchBar resignFirstResponder];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.searchResults.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DBMenuPositionSearchResult *searchResult = self.searchResults[section];
    
    return searchResult.positions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBSearchPositionTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBSearchPositionTableCell"];
    
    if (!cell) {
        cell = [DBSearchPositionTableCell create];
    }
    
    DBMenuPositionSearchResult *searchResult = self.searchResults[indexPath.section];
    [cell configureWithPosition:searchResult.positions[indexPath.row]];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DBMenuPositionSearchResult *searchResult = self.searchResults[section];
    
    NSMutableString *title = [NSMutableString stringWithString:searchResult.pathCategories.firstObject];
    for (int i = 1; i < searchResult.pathCategories.count; i++) {
        [title appendString:[NSString stringWithFormat:@"/ %@", searchResult.pathCategories[i]]];
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    view.backgroundColor = [UIColor colorWithRed:242./255 green:242./255 blue:242./255 alpha:1.0];
    UILabel *label = [UILabel new];
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.f];
    label.text = title;
    [view addSubview:label];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [label alignTop:@"0" leading:@"8" bottom:@"0" trailing:@"-8" toView:view];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DBMenuPositionSearchResult *searchResult = self.searchResults[indexPath.section];
    DBMenuPosition *position = searchResult.positions[indexPath.row];
    
    UIViewController<PositionViewControllerProtocol> *positionVC = [[ViewControllerManager positionViewController] initWithPosition:position mode:PositionViewControllerModeMenuPosition];
    [(UINavigationController *)_container pushViewController:positionVC animated:YES];
}

#pragma mark - Keyboard events

- (void)keyboardWillShow:(NSNotification *)notification{
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         CGRect rect = self.tableView.frame;
                         rect.size.height = self.view.frame.size.height - self.searchView.frame.size.height - keyboardRect.size.height;
                         self.tableView.frame = rect;
                     }
                     completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification{
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         CGRect rect = self.tableView.frame;
                         rect.size.height = self.view.frame.size.height - self.searchView.frame.size.height;
                         self.tableView.frame = rect;
                     }
                     completion:nil];
}

@end
