//
//  DBUnifiedSegmentViewController.m
//  DoubleB
//
//  Created by Balaban Alexander on 09/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBUnifiedSegmentViewController.h"

#import "DBUnifiedMenuTableViewController.h"

@interface DBUnifiedSegmentViewController ()

@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (strong, nonatomic) NSMutableArray *controllers;

@end

@implementation DBUnifiedSegmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.controllers = [NSMutableArray new];
    [self initializeControllers];
    [self showViewControllerWithIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeControllers {
    DBUnifiedMenuTableViewController *menuVC = [DBUnifiedMenuTableViewController new];
    [self.controllers addObject:menuVC];
    [self.controllers addObject:menuVC];
    [self.segmentedControl insertSegmentWithTitle:@"Menu" atIndex:0 animated:NO];
    [self.segmentedControl insertSegmentWithTitle:@"NeMenu" atIndex:0 animated:NO];
    self.segmentedControl.selectedSegmentIndex = 0;
}

- (IBAction)deliveryTypeChanged:(id)sender {
    [self showViewControllerWithIndex:self.segmentedControl.selectedSegmentIndex];
}

- (void)showViewControllerWithIndex:(NSInteger)index {
    UIViewController *controller;
    controller = self.controllers[index];
    [self setTitle:@"Menu"];
    [self addChildViewController:controller];
    controller.view.frame = [self.contentView bounds];
    [self.contentView addSubview:controller.view];
    [controller didMoveToParentViewController:self];
}

@end
