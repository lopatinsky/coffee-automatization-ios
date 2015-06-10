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


@interface DBDeliveryViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

#pragma mark - Fake Separators
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fakeSeparatorConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fakeSeparatorConstraint2;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fakeSeparatorConstraint4;

@property (strong, nonatomic) IBOutlet UIView *fakeSeparator;
@property (strong, nonatomic) IBOutlet UIView *fakeSeparator2;
@property (strong, nonatomic) IBOutlet UIView *fakeSeparator4;

#pragma mark - Text Fields
@property (strong, nonatomic) IBOutlet UILabel *cityTextLabel;
@property (strong, nonatomic) IBOutlet UITextField *streetTextField;
@property (strong, nonatomic) IBOutlet UITextField *apartmentTextField;

#pragma mark - Useful variables
@property (strong, nonatomic) IBOutlet UIView *streetIndicatorView;
@property (strong, nonatomic) IBOutlet UITableView *addressSuggestionsTableView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapOnCityLabelRecognizer;
@property (strong, nonatomic) IBOutlet UIView *deliveryView;
@property (strong, nonatomic) NSArray *addressSuggestions;
@property (strong, nonatomic) DeliveryManager *deliveryManager;
@property (nonatomic) BOOL keyboardIsHidden;

#pragma mark - Placeholders
@property (strong, nonatomic) NSMutableAttributedString *streetPlaceholder;
@property (strong, nonatomic) NSMutableAttributedString *apartmentPlaceholder;

@end

@implementation DBDeliveryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.deliveryManager = [DeliveryManager sharedManager];
    
    if ([[self.deliveryManager arrayOfCities] count] == 1) {
        self.tapOnCityLabelRecognizer.enabled = NO;
        self.deliveryManager.city = [self.deliveryManager arrayOfCities][0];
        self.cityTextLabel.text = [self.deliveryManager arrayOfCities][0];
    }
    
    if (![self.deliveryManager arrayOfCities]) {
        self.tapOnCityLabelRecognizer.enabled = NO;
        self.deliveryManager.city = @"Санкт-Петербург";
        self.cityTextLabel.text = @"Санкт-Петербург";
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestAddressSuggestions) name:DeliveryManagerDidRecieveSuggestionsNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear) name:UIKeyboardWillHideNotification object:nil];
    
    [self.streetTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.apartmentTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self initializeFakeSeparators];
    [self initializePlaceholders];
    [self initializeViews];
}

#pragma mark - Life-cycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)showPickerWithCities:(id)sender {

}

#pragma mark - Other functions
- (void)requestAddressSuggestions {
    self.addressSuggestions = [self.deliveryManager addressSuggestions];
    [self.addressSuggestionsTableView reloadData];
}

- (void)initializeFakeSeparators {
    self.fakeSeparatorConstraint.constant = 1. / [[UIScreen mainScreen] scale];
    self.fakeSeparatorConstraint2.constant = 1. / [[UIScreen mainScreen] scale];
    self.fakeSeparatorConstraint4.constant = 1. / [[UIScreen mainScreen] scale];
    
    self.fakeSeparator.backgroundColor = [UIColor db_defaultColor];
    self.fakeSeparator2.backgroundColor = [UIColor db_defaultColor];
    self.fakeSeparator4.backgroundColor = [UIColor db_defaultColor];
}

- (void)initializePlaceholders {
    self.streetPlaceholder = [[NSMutableAttributedString alloc] initWithString:@"Улица, дом (не указаны)"];
    [self.streetPlaceholder addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:15.0] range:NSMakeRange(0, 23)];
    [self.streetPlaceholder addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, 10)];
    
    self.apartmentPlaceholder = [[NSMutableAttributedString alloc] initWithString:@"Кв/Офис"];
    [self.apartmentPlaceholder addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:15.0] range:NSMakeRange(0, 7)];
    [self.apartmentPlaceholder addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, 7)];
}

- (void)initializeViews {
    self.addressSuggestionsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.streetIndicatorView.layer.cornerRadius = 4.0;
    self.streetIndicatorView.clipsToBounds = YES;
    self.streetIndicatorView.backgroundColor = [UIColor db_defaultColor];
    
    if (![self.deliveryManager.city isEqualToString:@""] &&
        [[self.deliveryManager arrayOfCities] containsObject:self.deliveryManager.city]) {
        self.cityTextLabel.text = self.deliveryManager.city;
    } else {
        // TODO: test with backend and uncomment
//        self.cityTextLabel.text = [[self.deliveryManager arrayOfCities] firstObject];
        self.cityTextLabel.text = @"Санкт-Петербург";
    }
    
    if (![self.deliveryManager.address isEqualToString:@""]) {
        self.streetTextField.text = self.deliveryManager.address;
        self.streetIndicatorView.hidden = YES;
    } else {
        self.streetTextField.attributedPlaceholder = self.streetPlaceholder;
        self.streetIndicatorView.hidden = NO;
    }
    self.streetTextField.enablesReturnKeyAutomatically = NO;
    
    if (![self.deliveryManager.apartment isEqualToString:@""]) {
        self.apartmentTextField.text = self.deliveryManager.apartment;
    } else {
        self.apartmentTextField.attributedPlaceholder = self.apartmentPlaceholder;
    }
    self.apartmentTextField.enablesReturnKeyAutomatically = NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self view] endEditing:YES];
}

- (void)keyboardWillAppear {
    self.keyboardIsHidden = NO;
}

- (void)keyboardWillDisappear {
    self.keyboardIsHidden = YES;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.delegate keyboardWillAppear];
    
    [UIView animateWithDuration:0.1 animations:^{
        [self.deliveryView setFrame:CGRectMake(self.deliveryView.frame.origin.x, self.deliveryView.frame.origin.y - 44, self.deliveryView.frame.size.width, self.deliveryView.frame.size.height)];
    }];
    if ([textField.text isEqualToString:@""]) {
        textField.placeholder = @"";
    }
    
    self.addressSuggestions = @[];
    [self.addressSuggestionsTableView reloadData];
    self.addressSuggestionsTableView.hidden = NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.1 animations:^{
        [self.deliveryView setFrame:CGRectMake(self.deliveryView.frame.origin.x, self.deliveryView.frame.origin.y + 44, self.deliveryView.frame.size.width, self.deliveryView.frame.size.height)];
    }];
    
    if (textField == self.streetTextField) {
        if ([textField.text isEqualToString:@""]) {
            textField.attributedPlaceholder = self.streetPlaceholder;
            self.streetIndicatorView.hidden = NO;
        } else {
            self.deliveryManager.address = self.streetTextField.text;
            self.streetIndicatorView.hidden = YES;
        }
    }
    if (textField == self.apartmentTextField) {
        if ([textField.text isEqualToString:@""]) {
            textField.attributedPlaceholder = self.apartmentPlaceholder;
        } else {
            self.deliveryManager.apartment = self.apartmentTextField.text;
        }
    }
}

- (void)textFieldDidChange:(UITextField *)sender {
    if (sender == self.streetTextField) {
        if ([self.streetTextField.text isEqualToString:@""]) {
            self.streetTextField.attributedPlaceholder = self.streetPlaceholder;
            self.streetIndicatorView.hidden = NO;
        } else {
            self.streetIndicatorView.hidden = YES;
        }
        self.deliveryManager.address = self.streetTextField.text;
    }
    if (sender == self.apartmentTextField) {
        if ([self.apartmentTextField.text isEqualToString:@""]) {
            self.apartmentTextField.attributedPlaceholder = self.apartmentPlaceholder;
        }
        self.deliveryManager.apartment = self.apartmentTextField.text;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    self.addressSuggestionsTableView.hidden = YES;
    [self.delegate keyboardWillDisappear];
    
    return YES;
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [[self.deliveryManager arrayOfCities] count];
}

#pragma mark - UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.deliveryManager arrayOfCities][row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.addressSuggestions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    cell.textLabel.text = self.addressSuggestions[indexPath.row][@"address"][@"street"];
    [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0]];
    
    if (![self.addressSuggestions[indexPath.row][@"address"][@"home"] isKindOfClass:[NSNull class]]) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", cell.textLabel.text, self.addressSuggestions[indexPath.row][@"address"][@"home"]];
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.addressSuggestionsTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.deliveryManager.address = self.addressSuggestions[indexPath.row][@"address"][@"street"];
    if (![self.addressSuggestions[indexPath.row][@"address"][@"home"] isKindOfClass:[NSNull class]]) {
        self.deliveryManager.address = [NSString stringWithFormat:@"%@, %@",
                                        self.deliveryManager.address, self.addressSuggestions[indexPath.row][@"address"][@"home"]];
    }
    self.streetTextField.text = self.deliveryManager.address;
    
    if (self.keyboardIsHidden) {
        self.addressSuggestionsTableView.hidden = YES;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.streetTextField resignFirstResponder];
    [self.apartmentTextField resignFirstResponder];
    [self.delegate keyboardWillDisappear];
}

@end
