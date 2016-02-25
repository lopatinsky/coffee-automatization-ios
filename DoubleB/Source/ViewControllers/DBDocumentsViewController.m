//
//  DBDocumentsViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 02.06.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBDocumentsViewController.h"
#import "DBHTMLViewController.h"
#import "DBSettingsCell.h"

@interface DBDocumentsViewController ()
@property (strong, nonatomic) NSMutableArray *items;
@end

@implementation DBDocumentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Справка", nil);
    self.view.backgroundColor = [UIColor db_backgroundColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.rowHeight = 50;
    
    self.items = [[NSMutableArray alloc] init];
    
    // About app
    DBHTMLViewController *aboutAppVC = [DBHTMLViewController new];
    aboutAppVC.title = NSLocalizedString(@"О приложении", nil);
    aboutAppVC.url = [DBCompanyInfo db_aboutAppUrl];
    aboutAppVC.screen = ABOUT_APP_SCREEN;
    [self.items addObject:@{@"title": NSLocalizedString(@"О приложении", nil),
                            @"viewController": aboutAppVC}];
    
    // Licence Agreement
    DBHTMLViewController *licenceVC = [DBHTMLViewController new];
    licenceVC.title = NSLocalizedString(@"Лицензионное соглашение", nil);
    licenceVC.url = [DBCompanyInfo db_licenceUrl];
    licenceVC.screen = LICENCE_AGREEMENT_SCREEN;
    [self.items addObject:@{@"title": NSLocalizedString(@"Лицензионное соглашение", nil),
                            @"viewController": licenceVC}];
    
    // Licence Agreement
    DBHTMLViewController *paymentVC = [DBHTMLViewController new];
    paymentVC.title = NSLocalizedString(@"Правила оплаты", nil);
    paymentVC.url = [DBCompanyInfo db_paymentRulesUrl];
    paymentVC.screen = PAYMENT_RULES_SCREEN;
    [self.items addObject:@{@"title": NSLocalizedString(@"Правила оплаты", nil),
                            @"viewController": paymentVC}];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [GANHelper analyzeScreen:DOCS_SCREEN];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.items count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBSettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBSettingsCell"];
    
    if (!cell) {
        cell = [DBSettingsCell new];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.hasIcon = NO;
    }
    
    NSDictionary *itemDict = self.items[indexPath.row];
    cell.titleLabel.text = itemDict[@"title"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *itemDict = self.items[indexPath.row];
    [self.navigationController pushViewController:itemDict[@"viewController"] animated:YES];
}

#pragma mark - DBSettingsProtocol

+ (id<DBSettingsItemProtocol>)settingsItem {
    DBSettingsItem *settingsItem = [DBSettingsItem new];
    
    settingsItem.name = @"documentsVC";
    settingsItem.iconName = @"about";
    settingsItem.title = NSLocalizedString(@"Справка", nil);
    settingsItem.eventLabel = @"documents_click";
    settingsItem.viewController = [DBDocumentsViewController new];
    settingsItem.navigationType = DBSettingsItemNavigationPush;
    
    return settingsItem;
}

@end
