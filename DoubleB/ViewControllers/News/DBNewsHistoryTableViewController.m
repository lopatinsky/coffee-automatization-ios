//
//  DBNewsHistoryTableViewController.m
//  DoubleB
//
//  Created by Balaban Alexander on 27/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBNewsHistoryTableViewController.h"

#import "CompanyNewsManager.h"
#import "NewsHistoryTableViewCell.h"
#import "NewsImageHistoryTableViewCell.h"

#import "UIImageView+WebCache.h"

@interface DBNewsHistoryTableViewController ()

@property (nonatomic, strong) NSArray *companyNews;

@end

@implementation DBNewsHistoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self db_setTitle:NSLocalizedString(@"Новости", nil)];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 160;
    } else {
        self.tableView.rowHeight = 120;
    }
    [self.tableView registerNib:[UINib nibWithNibName:@"NewsHistoryTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"HistoryNewsCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"NewsImageHistoryTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"HistoryNewsImageCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:CompanyNewsManagerDidFetchActualNews object:nil];
    [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [[CompanyNewsManager sharedManager] fetchUpdates];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadData {
    self.companyNews = [[CompanyNewsManager sharedManager] allNews];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.companyNews count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![[self.companyNews[indexPath.row] imageURL] isEqualToString:@""]) {
        NewsImageHistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryNewsImageCell" forIndexPath:indexPath];
        
        [cell.newsImageView sd_setImageWithURL:[NSURL URLWithString:[self.companyNews[indexPath.row] imageURL]]];
        cell.newsTextLabel.text = [self.companyNews[indexPath.row] text];
        cell.titleLabel.text = [self.companyNews[indexPath.row] title];
        
        return cell;
    } else {
        NewsHistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryNewsCell" forIndexPath:indexPath];
        
        cell.newsTextLabel.text = [self.companyNews[indexPath.row] text];
        cell.titleLabel.text = [self.companyNews[indexPath.row] title];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
        return UITableViewAutomaticDimension;
    } else {
        return 120;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
