//
//  DBDemoStartNavController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBDemoStartNavController.h"
#import "DBDemoLoginViewController.h"

@interface DBDemoStartNavController ()<DBDemoLoginViewControllerDelegate>

@end

@implementation DBDemoStartNavController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (![self needLaunchScreen]) {
        [self moveNext];
    }
}

- (void)additionalLaunchScreenActions {
    [self moveNext];
}

- (void)moveNext {
    if ([DBCompanyInfo sharedInstance].infoLoaded) {
        [self moveToMain];
    } else {
        [self moveToLogin];
    }
}

- (void)moveToLogin {
    DBDemoLoginViewController *loginVC = [DBDemoLoginViewController new];
    loginVC.delegate = self;
    [self setViewControllers:@[loginVC] animated:YES];
}

- (void)moveToMain {
    if ([self.navDelegate respondsToSelector:@selector(db_startNavVCNeedsMoveToMain:)]) {
        [self.navDelegate db_startNavVCNeedsMoveToMain:self];
    }
}

#pragma mark - DBDemoLoginViewControllerDelegate
- (void)db_demoLoginVCLoggedIn:(DBDemoLoginViewController *)controller {
    [self moveToMain];
}
@end
