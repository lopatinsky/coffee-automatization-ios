//
//  DBDeliveryViewController.m
//  DoubleB
//
//  Created by Dmitriy Stupivtsev on 10.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DeliveryManager.h"
#import "DBDeliveryViewController.h"
#import "UIColor+Brandbook.h"

#import "QuartzCore/QuartzCore.h"


@interface DBDeliveryViewController () <UITextFieldDelegate>

#pragma mark - Fake Separators
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fakeSeparatorConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fakeSeparatorConstraint2;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fakeSeparatorConstraint3;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fakeSeparatorConstraint4;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fakeSeparatorConstraint5;

@property (strong, nonatomic) IBOutlet UIView *fakeSeparator;
@property (strong, nonatomic) IBOutlet UIView *fakeSeparator2;
@property (strong, nonatomic) IBOutlet UIView *fakeSeparator3;
@property (strong, nonatomic) IBOutlet UIView *fakeSeparator4;
@property (strong, nonatomic) IBOutlet UIView *fakeSeparator5;

#pragma mark - Text Fields
@property (strong, nonatomic) IBOutlet UITextField *cityTextField;
@property (strong, nonatomic) IBOutlet UITextField *streetTextField;
@property (strong, nonatomic) IBOutlet UITextField *houseTextField;
@property (strong, nonatomic) IBOutlet UITextField *corpusTextField;
@property (strong, nonatomic) IBOutlet UITextField *apartmentTextField;

#pragma mark - Useful variables
@property (strong, nonatomic) DeliveryManager *deliveryManager;
@property (strong, nonatomic) NSArray *addressSuggestions;

@end

@implementation DBDeliveryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    [self initializeFakeSeparators];
    
    self.deliveryManager = [DeliveryManager sharedManager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestAddressSuggestions) name:DeliveryManagerDidRecieveSuggestionsNotification object:nil];
}

#pragma mark - Life-cycle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Custom users
- (void)requestAddressSuggestions {
    self.addressSuggestions = [self.deliveryManager addressSuggestions];
}

- (void)initializeFakeSeparators {
    self.fakeSeparatorConstraint.constant = 1. / [[UIScreen mainScreen] scale];
    self.fakeSeparatorConstraint2.constant = 1. / [[UIScreen mainScreen] scale];
    self.fakeSeparatorConstraint3.constant = 1. / [[UIScreen mainScreen] scale];
    self.fakeSeparatorConstraint4.constant = 1. / [[UIScreen mainScreen] scale];
    self.fakeSeparatorConstraint5.constant = 1. / [[UIScreen mainScreen] scale];
    
    self.fakeSeparator.backgroundColor = [UIColor db_defaultColor];
    self.fakeSeparator2.backgroundColor = [UIColor db_defaultColor];
    self.fakeSeparator3.backgroundColor = [UIColor db_defaultColor];
    self.fakeSeparator4.backgroundColor = [UIColor db_defaultColor];
    self.fakeSeparator5.backgroundColor = [UIColor db_defaultColor];
}

#pragma mark - UITextFieldDelegate


@end
