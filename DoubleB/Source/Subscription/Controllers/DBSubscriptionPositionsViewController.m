//
//  DBSubscriptionPositionsViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 21/01/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBSubscriptionPositionsViewController.h"
#import "DBSubscriptionManager.h"
#import "DBSubscriptionModuleView.h"
#import "DBBarButtonItem.h"
#import "DBMenuCategory.h"

@interface DBSubscriptionPositionsViewController ()

@end

@implementation DBSubscriptionPositionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self db_setTitle:[DBSubscriptionManager sharedInstance].subscriptionCategory.name];
    
    self.analyticsCategory = @"Menu_subscription_positions_screen";
    
    self.navigationItem.rightBarButtonItem = [DBBarButtonItem orderItem:self action:@selector(moveToOrder)];
    
    DBSubscriptionModuleView *moduleView = [DBSubscriptionModuleView create:DBSubscriptionModuleViewModePositions];
    [self addModule:moduleView];
    [self layoutModules];
    
}

- (void)moveToOrder {
    [self.navigationController pushViewController:[DBClassLoader loadNewOrderVC] animated:YES];
    [GANHelper analyzeEvent:@"order_pressed" category:self.analyticsCategory];
}

@end
