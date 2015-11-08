//
//  DBCitiesViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 08/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBCitiesViewController.h"
#import "DBCityVariantCell.h"

@interface DBCitiesViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *cityView;
@property (weak, nonatomic) IBOutlet UITextField *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityTextField;
@property (weak, nonatomic) IBOutlet UITableView *citiesTableView;

@end

@implementation DBCitiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self db_setTitle:NSLocalizedString(@"Выберите ваш город", nil)];
    
    self.citiesTableView.dataSource = self;
    self.citiesTableView.delegate = self;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBCityVariantCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DBCityVariantCell"];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DBCityVariantCell" owner:self options:nil] firstObject];
    }
    
    NSString *city = 
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}


@end
