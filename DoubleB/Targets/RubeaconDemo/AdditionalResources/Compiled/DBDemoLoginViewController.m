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

@interface DBDemoLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *loginTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *demoButton;

@end

@implementation DBDemoLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor db_defaultColor];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (IBAction)loginButtonClick:(id)sender {
    NSString *login = self.loginTextField.text;
    NSString *password = self.passwordTextField.text;
    
    if(login.length > 0 && password.length > 0){
        [DBServerAPI demoLogin:login
                      password:password
                      callback:^(BOOL success, NSString *namespace) {
                          if(success){
                              [[DBAPIClient sharedClient] enableCompanyHeader:namespace];
                              [self moveForward];
                          } else {
                              [self showError:@"Неверная пара логин/пароль"];
                          }
                      }];
    }
}

- (IBAction)demoButtonClick:(id)sender {
    [self moveForward];
}

- (void)moveForward{
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] window].rootViewController = [DBTabBarController sharedInstance];
//    [UIView transitionWithView:[(AppDelegate *)[[UIApplication sharedApplication] delegate] window]
//                      duration:0.5
//                       options:UIViewAnimationOptionTransitionNone
//                    animations:^{
//                        [(AppDelegate *)[[UIApplication sharedApplication] delegate] window].rootViewController = [DBTabBarController sharedInstance];
//                    }
//                    completion:nil];
}


@end
