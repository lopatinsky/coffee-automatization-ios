//
//  DBDemoLoginViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 03.07.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBDemoLoginViewController.h"
#import "AppDelegate.h"
#import "DBTabBarController.h"
#import "DBServerAPI+DemoLogin.h"
#import "DBAPIClient.h"
#import "MBProgressHUD.h"

#import "ApplicationManager.h"
#import "DBDemoManager.h"
#import "DBCompaniesManager.h"

@interface DBDemoLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *loginTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *demoButton;
@end

@implementation DBDemoLoginViewController{
    CAGradientLayer *_gradientLayer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = self.view.bounds;
        _gradientLayer.colors = @[(id)[UIColor fromHex:0xff65331f].CGColor, (id)[UIColor fromHex:0xff331305].CGColor];
        _gradientLayer.startPoint = CGPointMake(0.5, 0.0);
        _gradientLayer.endPoint = CGPointMake(0.5, 1.0);
        [self.view.layer insertSublayer:_gradientLayer atIndex:0];
    }
}

- (IBAction)loginButtonClick:(id)sender {
    NSString *login = self.loginTextField.text;
    NSString *password = self.passwordTextField.text;
    
    if(login.length > 0 && password.length > 0){
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [DBServerAPI demoLogin:login
                      password:password
                       success:^(DBCompany *company) {
                           [self selectCompany:company];
                       } failure:^(NSString *description) {
                           [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
                           NSString *message = description ?: @"Неверная пара логин/пароль";
                           [self showError:message];
                       }];
    }
}

- (IBAction)demoButtonClick:(id)sender {
    [self selectCompany:nil];
}

- (void)selectCompany:(DBCompany *)company {
    [[ApplicationManager sharedInstance] flushStoredCache];
    
    [DBCompaniesManager selectCompany:company];
    [DBDemoManager sharedInstance].state = company ? DBDemoManagerStateCompany : DBDemoManagerStateDemo;
    
    [[DBCompanyInfo sharedInstance] updateInfo:^(BOOL success) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if(success){
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            delegate.window.rootViewController = [ViewControllerManager mainViewController];
        } else {
            [self showError:@"Не удалось загрузить информацию о выбранной компании"];
        }
    }];
    
    [[ApplicationManager sharedInstance] fetchCompanyDependentInfo];
}


@end
