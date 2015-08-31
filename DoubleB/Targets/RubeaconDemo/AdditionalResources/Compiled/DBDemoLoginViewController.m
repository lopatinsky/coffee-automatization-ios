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
#import "DBCompaniesManager.h"

@interface DBDemoLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *loginTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *demoButton;

@property (nonatomic) BOOL inProcess;

@end

@implementation DBDemoLoginViewController{
    CAGradientLayer *_gradientLayer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(firstLaunchNecessaryInfoLoadSuccessNotification:)
                                                 name:kDBApplicationManagerInfoLoadSuccess
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(firstLaunchNecessaryInfoLoadFailureNotification:)
                                                 name:kDBApplicationManagerInfoLoadFailure
                                               object:nil];
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


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (IBAction)loginButtonClick:(id)sender {
    NSString *login = self.loginTextField.text;
    NSString *password = self.passwordTextField.text;
    
    if(login.length > 0 && password.length > 0){
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [DBServerAPI demoLogin:login
                      password:password
                      callback:^(BOOL success, NSString *result) {
                          if(success){
                              _inProcess = YES;
                              
                              [[ApplicationManager sharedInstance] flushStoredCache];
                              [DBCompaniesManager selectCompanyName:result];
                              
                              [[ApplicationManager sharedInstance] updateAllInfo:nil];
                          } else {
                              [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                              
                              NSString *message = result ?: @"Неверная пара логин/пароль";
                              [self showError:message];
                          }
                      }];
    }
}

- (IBAction)demoButtonClick:(id)sender {
    if(![ApplicationManager sharedInstance].allInfoLoaded){
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _inProcess = YES;
        
        [[ApplicationManager sharedInstance] flushStoredCache];
        [DBCompaniesManager selectCompanyName:nil];
        
        [[ApplicationManager sharedInstance] updateAllInfo:nil];
    } else {
        [self moveForward];
    }
}

- (void)moveForward {
    [[DBTabBarController sharedInstance] moveToStartState];
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] window].rootViewController = [DBTabBarController sharedInstance];
}

- (void)firstLaunchNecessaryInfoLoadSuccessNotification:(NSNotification *)notification{
    if(_inProcess){
        _inProcess = NO;
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self moveForward];
    }
}

- (void)firstLaunchNecessaryInfoLoadFailureNotification:(NSNotification *)notification{
    if(_inProcess){
        _inProcess = NO;
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self showAlert:@"Не удается настроить приложение, поскольку отсутствует интернет-соединение"];
    }
}


@end
