//
//  DBCitiesViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBCitiesViewController.h"
#import "NetworkManager.h"

@interface DBCitiesViewController ()

@end

@implementation DBCitiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(citiesAreBecomeAvailable) name:kDBConcurrentOperationUnifiedCitiesLoadSuccess object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(citiesDownloadFailed) name:kDBConcurrentOperationUnifiedCitiesLoadFailure object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [[NetworkManager sharedManager] addPendingOperation:NetworkOperationFetchUnifiedCities];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Networking
- (void)citiesAreBecomeAvailable {
    
}

- (void)citiesDownloadFailed {
    
}

@end
