//
//  DBDemoLoginViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 03.07.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBDemoLoginViewController.h"
#import "AppDelegate.h"
#import "DBServerAPI+DemoLogin.h"
#import "DBAPIClient.h"

#import "ApplicationManager.h"
#import "DBDemoManager.h"
#import "DBCompaniesManager.h"

@interface DBDemoLoginViewController ()<UITextFieldDelegate>
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
    
    [self.loginButton setTitle:NSLocalizedString(@"Войти", nil) forState:UIControlStateNormal];
    [self.demoButton setTitle:NSLocalizedString(@"Пропустить", nil) forState:UIControlStateNormal];
    
    self.loginTextField.placeholder = NSLocalizedString(@"Логин", nil);
    self.passwordTextField.placeholder = NSLocalizedString(@"Пароль", nil);
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.loginTextField.delegate = self;
    self.passwordTextField.delegate = self;
    
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = self.view.bounds;
        _gradientLayer.colors = @[(id)[UIColor fromHex:0xff65331f].CGColor, (id)[UIColor fromHex:0xff331305].CGColor];
        _gradientLayer.startPoint = CGPointMake(0.5, 0.0);
        _gradientLayer.endPoint = CGPointMake(0.5, 1.0);
        [self.view.layer insertSublayer:_gradientLayer atIndex:0];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
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
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[DBCompanyInfo sharedInstance] updateInfo:^(BOOL success) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        [ApplicationManager applyBrandbookStyle];
        
        if(success){
            if ([self.delegate respondsToSelector:@selector(db_demoLoginVCLoggedIn:)]) {
                [self.delegate db_demoLoginVCLoggedIn:self];
            }
        } else {
            [self showError:@"Не удалось загрузить информацию о выбранной компании"];
        }
    }];
    
    [[DBCompanyInfo sharedInstance] fetchDependentInfo];
}

#pragma mark - DBSettingsProtocol

+ (id<DBSettingsItemProtocol>)settingsItem {
    DBDemoLoginViewController *loginVC = [DBDemoLoginViewController new];
    DBSettingsItem *settingsItem = [DBSettingsItem new];
    
    settingsItem.name = @"profileVC";
    settingsItem.title = NSLocalizedString(@"Выйти", nil);
    settingsItem.iconName = @"exit_icon";
    settingsItem.viewController = loginVC;
    settingsItem.eventLabel = @"logout_click";
    settingsItem.block = ^(UIViewController *vc) {
        [[ApplicationManager sharedInstance] flushStoredCache];
        [DBCompaniesManager selectCompany:nil];
        
        [[ApplicationManager sharedInstance] moveToStartState:YES];
    };
    
    return settingsItem;
}


@end
