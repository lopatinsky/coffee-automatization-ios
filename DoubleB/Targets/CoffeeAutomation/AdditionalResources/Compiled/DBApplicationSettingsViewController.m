//
//  DBApplicationSettingsViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 21.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBApplicationSettingsViewController.h"
#import "AppDelegate.h"
#import "DBAPIClient.h"

@interface DBApplicationSettingsViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *magicButton;

@property (strong, nonatomic) NSArray *applications;

@property (strong, nonatomic) MBProgressHUD *hud;
@end

@implementation DBApplicationSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.hud = [[MBProgressHUD alloc] init];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    
    [self.magicButton addTarget:self action:@selector(magicButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.urlTextField.text = [self appUrl];
    self.urlTextField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated{
    [self.hud show:YES];
    [self updateList];
}

- (NSString *)appUrl {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths firstObject];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"CompanyInfo.plist"];
    NSDictionary *companyDict = [NSDictionary dictionaryWithContentsOfFile:path];
    
    return companyDict[@"Preferences"][@"BaseUrl"];
}

- (void)magicButtonClick {
    NSString *resultUrl = self.urlTextField.text;
    
    if(resultUrl && resultUrl.length > 0){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths firstObject];
        NSString *path = [documentDirectory stringByAppendingPathComponent:@"CompanyInfo.plist"];
        NSDictionary *companyDict = [NSDictionary dictionaryWithContentsOfFile:path];
        
        NSMutableDictionary *companyInfo = [[NSMutableDictionary alloc] initWithDictionary:companyDict];
        if ([resultUrl characterAtIndex:resultUrl.length - 1] != '/') {
            resultUrl = [resultUrl stringByAppendingString:@"/"];
        }
        companyInfo[@"Preferences"][@"BaseUrl"] = resultUrl;
        
        [companyInfo writeToFile:path atomically:NO];
        
        
        [[ApplicationManager sharedInstance] flushStoredCache];
        [DBAPIClient changeBaseUrl];
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[DBCompanyInfo sharedInstance] updateInfo:^(BOOL success) {
            [[DBMenu sharedInstance] updateMenu:^(BOOL success, NSArray *categories) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                
                if(success){
                    [[ApplicationManager sharedInstance] moveToScreen:ApplicationScreenRoot animated:YES];
                } else {
                    [self showError:@"Не удалось загрузить информацию о выбранной компании"];
                }
            }];
        }];
        [[DBCompanyInfo sharedInstance] fetchDependentInfo];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.urlTextField endEditing:YES];
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.applications count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellIdentifier"];
    }
    
    cell.textLabel.text = self.applications[indexPath.row][@"app_name"];
    
    return cell;
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *appUrl = [self.applications[indexPath.row] getValueForKey:@"base_url"];
    
    self.urlTextField.text = appUrl;
}

- (void)updateList{
    [[DBAPIClient sharedClient] GET:@"http://test.doubleb-automation-production.appspot.com/api/company/base_urls"
                         parameters:nil
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                                NSLog(@"%@", responseObject);
                                
                                [self.hud hide:YES];
                                
                                NSMutableArray *array = [NSMutableArray new];
                                for(NSDictionary *companyDict in responseObject[@"companies"]){
                                    if([companyDict getValueForKey:@"app_name"]){
                                        [array addObject:companyDict];
                                    }
                                }
                                self.applications = array;
                                [self.tableView reloadData];
                                
                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"%@", error);
                                
                                [self.hud hide:YES];
                            }];
}

#pragma mark - DBSettingsProtocol

+ (id<DBSettingsItemProtocol>)settingsItem {
    DBApplicationSettingsViewController *applicationSettingsVC = [DBApplicationSettingsViewController new];
    DBSettingsItem *settingsItem = [DBSettingsItem new];
    
    settingsItem.name = @"appSetterVC";
    settingsItem.title = @"Выбрать приложение";
    settingsItem.iconName = @"none";
    settingsItem.viewController = applicationSettingsVC;
    settingsItem.navigationType = DBSettingsItemNavigationPush;
    
    return settingsItem;
}

@end
