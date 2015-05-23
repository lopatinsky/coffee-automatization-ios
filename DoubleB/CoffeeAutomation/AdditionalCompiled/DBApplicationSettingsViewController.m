//
//  DBApplicationSettingsViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 21.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBApplicationSettingsViewController.h"
#import "DBAPIClient.h"
#import "MBProgressHUD.h"

@interface DBApplicationSettingsViewController ()
@property (strong, nonatomic) NSArray *applications;

@property (strong, nonatomic) MBProgressHUD *hud;
@end

@implementation DBApplicationSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hud = [[MBProgressHUD alloc] init];
    
    self.tableView.tableFooterView = [UIView new];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.hud show:YES];
    [self updateList];
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
    
    if(appUrl && appUrl.length > 0){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths firstObject];
        NSString *path = [documentDirectory stringByAppendingString:@"CompanyInfo.plist"];
        NSDictionary *companyDict = [NSDictionary dictionaryWithContentsOfFile:path];
        
        NSMutableDictionary *companyInfo = [[NSMutableDictionary alloc] initWithDictionary:companyDict];
        companyInfo[@"BaseUrl"] = appUrl;
        
        [companyInfo writeToFile:path atomically:NO];
        
        [[[UIAlertView alloc] initWithTitle:@"Важно!"
                                    message:@"Чтобы изменения вступили в силу, перезапустите приложение!"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

- (void)updateList{
    [[DBAPIClient sharedClient] GET:@"http://doubleb-automation-production.appspot.com/api/company/base_urls"
                         parameters:nil
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                NSLog(@"%@", responseObject);
                                
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


@end
