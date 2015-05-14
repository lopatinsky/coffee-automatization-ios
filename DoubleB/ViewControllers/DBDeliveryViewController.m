//
//  DBDeliveryViewController.m
//  DoubleB
//
//  Created by Dmitriy Stupivtsev on 10.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBDeliveryViewController.h"

@interface DBDeliveryViewController ()
@property (weak, nonatomic) IBOutlet UIView *line1View;
@property (weak, nonatomic) IBOutlet UIView *line2View;
@property (weak, nonatomic) IBOutlet UIView *line3View;
@property (weak, nonatomic) IBOutlet UIView *line4View;
@property (weak, nonatomic) IBOutlet UIView *line5View;
@property (weak, nonatomic) IBOutlet UIView *line6View;

@property (weak, nonatomic) IBOutlet UIView *circleStreetView;
@property (weak, nonatomic) IBOutlet UIView *circleHouseView;

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;

@property (weak, nonatomic) IBOutlet UITextField *streetTextField;
@property (weak, nonatomic) IBOutlet UITextField *houseTextField;
@property (weak, nonatomic) IBOutlet UITextField *housingTextField;
@property (weak, nonatomic) IBOutlet UITextField *ApartmentTextField;
@end

@implementation DBDeliveryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor db_backgroundColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
