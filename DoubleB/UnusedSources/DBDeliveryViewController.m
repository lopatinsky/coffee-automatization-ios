//
//  DBDeliveryViewController.m
//  DoubleB
//
//  Created by Dmitriy Stupivtsev on 10.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "GANHelper.h"

#import "OrderCoordinator.h"
#import "ShippingManager.h"
#import "DBDeliveryViewController.h"
#import "DBCompaniesManager.h"
#import "DBPickerView.h"
#import "UIColor+Brandbook.h"

#import "QuartzCore/QuartzCore.h"

typedef enum : NSUInteger {
    StreetKeyboard,
    Commentkeyboard,
    NoKeyboard,
} KeyboardStatus;

@interface DBDeliveryViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, DBPickerViewDelegate, DBPopupViewComponentDelegate>


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintCityViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintStreetViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintCommentViewHeight;

@property (nonatomic) double initialCityViewHeight;
@property (nonatomic) double initialStreetViewHeight;
@property (nonatomic) double initialCommentViewHeight;

#pragma mark - Fake Separators
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fakeSeparatorConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fakeSeparatorConstraint2;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fakeSeparatorConstraint4;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fakeSeparatorConstraint8;

@property (strong, nonatomic) IBOutlet UIView *fakeSeparator;
@property (strong, nonatomic) IBOutlet UIView *fakeSeparator2;
@property (strong, nonatomic) IBOutlet UIView *fakeSeparator4;
@property (strong, nonatomic) IBOutlet UIView *fakeSeparator8;

#pragma mark - Text Fields
@property (strong, nonatomic) IBOutlet UILabel *cityTextLabel;
@property (strong, nonatomic) IBOutlet UITextField *streetTextField;
@property (strong, nonatomic) IBOutlet UITextField *apartmentTextField;
@property (strong, nonatomic) IBOutlet UITextField *commentTextField;

#pragma mark - Useful variables
@property (strong, nonatomic) IBOutlet UIView *streetIndicatorView;
@property (strong, nonatomic) IBOutlet UIView *commentIndicatorView;
@property (strong, nonatomic) IBOutlet UITableView *addressSuggestionsTableView;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapOnCityLabelRecognizer;
@property (strong, nonatomic) IBOutlet UIView *deliveryView;

@property (strong, nonatomic) ShippingManager *shippingManager;

@property (strong, nonatomic) DBPickerView *cityPickerView;
@property (strong, nonatomic) NSArray *addressSuggestions;
@property (nonatomic) BOOL keyboardIsHidden;

@end

@implementation DBDeliveryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self db_setTitle:NSLocalizedString(@"Доставка", nil)];
    
    self.shippingManager = [OrderCoordinator sharedInstance].shippingManager;
    
    if ([[self.shippingManager arrayOfCities] count] == 1 || ![self.shippingManager arrayOfCities]) {
        self.tapOnCityLabelRecognizer.enabled = NO;
    }
    
    [[OrderCoordinator sharedInstance] addObserver:self withKeyPath:CoordinatorNotificationAddressSuggestionsUpdated selector:@selector(requestAddressSuggestions)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear) name:UIKeyboardWillHideNotification object:nil];
    
    [self.streetTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.apartmentTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.commentTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.initialCityViewHeight = self.constraintCityViewHeight.constant;
    self.initialStreetViewHeight = self.constraintStreetViewHeight.constant;
    self.initialCommentViewHeight = self.constraintCommentViewHeight.constant;
    
    [self initializeFakeSeparators];
    [self initializePlaceholders];
    [self initializeViews];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self reload];
}

#pragma mark - Life-cycle
- (void)dealloc {
    [[OrderCoordinator sharedInstance] removeObserver:self];
}

- (IBAction)showPickerWithCities:(id)sender {
    [self.cityPickerView configureWithItems:[self.shippingManager arrayOfCities]];
    self.cityPickerView.selectedIndex = [[self.shippingManager arrayOfCities] indexOfObject:self.shippingManager.selectedAddress.city];
    
    [self.cityPickerView showOnView:self.navigationController.view withAppearance:DBPopupViewComponentAppearanceModal];
    [GANHelper analyzeEvent:@"city_spinner_show" category:ADDRESS_SCREEN];
}

#pragma mark - Other functions

- (void)reload{
    self.cityTextLabel.text = self.shippingManager.selectedAddress.city;
    self.streetTextField.text = [self.shippingManager.selectedAddress formattedAddressString:DBAddressStringModeAutocomplete];
    if(self.streetTextField.text.length > 0){
        self.streetIndicatorView.hidden = YES;
    } else {
        self.streetTextField.hidden = NO;
    }
    
    self.apartmentTextField.text = self.shippingManager.selectedAddress.apartment;
    self.commentTextField.text = self.shippingManager.selectedAddress.comment;
    if (self.commentTextField.text.length > 0){
        self.commentIndicatorView.hidden = YES;
    } else {
        self.commentIndicatorView.hidden = NO;
    }
}

- (void)requestAddressSuggestions {
    self.addressSuggestions = [self.shippingManager addressSuggestions];
    [self.addressSuggestionsTableView reloadData];
    
    [GANHelper analyzeEvent:@"autocomplete_list_show" number:@([self.addressSuggestions count]) category:ADDRESS_SCREEN];
}

- (void)initializeFakeSeparators {
    self.fakeSeparatorConstraint.constant = 1. / [[UIScreen mainScreen] scale];
    self.fakeSeparatorConstraint2.constant = 1. / [[UIScreen mainScreen] scale];
    self.fakeSeparatorConstraint4.constant = 1. / [[UIScreen mainScreen] scale];
    self.fakeSeparatorConstraint8.constant = 1. / [[UIScreen mainScreen] scale];
    
    self.fakeSeparator.backgroundColor = [UIColor db_defaultColor];
    self.fakeSeparator2.backgroundColor = [UIColor db_defaultColor];
    self.fakeSeparator4.backgroundColor = [UIColor db_defaultColor];
    self.fakeSeparator8.backgroundColor = [UIColor db_defaultColor];
}

- (void)initializePlaceholders {
    self.streetTextField.placeholder = NSLocalizedString(@"Улица, дом", nil);
    self.apartmentTextField.placeholder = NSLocalizedString(@"Кв/Офис", nil);
    self.commentTextField.placeholder = NSLocalizedString(@"Комментарий", nil);
}

- (void)initializeViews {
    self.addressSuggestionsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.streetIndicatorView.layer.cornerRadius = 4.0;
    self.streetIndicatorView.clipsToBounds = YES;
    self.streetIndicatorView.backgroundColor = [UIColor db_defaultColor];
    
    self.commentIndicatorView.layer.cornerRadius = 4.0;
    self.commentIndicatorView.clipsToBounds = YES;
    self.commentIndicatorView.backgroundColor = [UIColor db_defaultColor];
    
    self.streetTextField.enablesReturnKeyAutomatically = NO;
    self.apartmentTextField.enablesReturnKeyAutomatically = NO;
    self.commentTextField.enablesReturnKeyAutomatically = NO;
    
    self.cityPickerView = [DBPickerView new];
    self.cityPickerView.pickerDelegate = self;
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

- (void)switchToCompactMode{
    [UIView animateWithDuration:0.1 animations:^{
        self.constraintCityViewHeight.constant = 0.f;
        self.constraintCommentViewHeight.constant = 0.f;
        [self.view layoutIfNeeded];
    }];
}

- (void)switchToFullMode{
    [UIView animateWithDuration:0.1 animations:^{
        self.constraintCityViewHeight.constant = self.initialCityViewHeight;
        self.constraintCommentViewHeight.constant = self.initialCommentViewHeight;
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.delegate keyboardWillAppear];
    
    self.addressSuggestionsTableView.hidden = YES;
    
    if (textField == self.streetTextField) {
        [self switchToCompactMode];
        self.addressSuggestionsTableView.hidden = NO;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self switchToFullMode];
    
    [self.delegate keyboardWillDisappear];
    if(textField == self.streetTextField){
        if ([textField.text isEqualToString:@""]) {
            self.streetIndicatorView.hidden = NO;
        } else {
            self.streetIndicatorView.hidden = YES;
        }
    }
    
    if (textField == self.apartmentTextField) {
        [self.shippingManager setApartment:self.apartmentTextField.text];
    }
    
    if(textField == self.commentTextField){
        if ([textField.text isEqualToString:@""]) {
            self.commentIndicatorView.hidden = NO;
        } else {
            self.commentIndicatorView.hidden = YES;
        }
    }
}

- (void)textFieldDidChange:(UITextField *)sender {
    if (sender == self.streetTextField) {
        if ([self.streetTextField.text isEqualToString:@""]) {
            self.streetIndicatorView.hidden = NO;
        } else {
            self.streetIndicatorView.hidden = YES;
        }
        [self.shippingManager setAddress:self.streetTextField.text];
        [self.shippingManager requestSuggestions];
        
        [GANHelper analyzeEvent:@"street_text_changed" label:self.streetTextField.text category:ADDRESS_SCREEN];
    }
    
    if (sender == self.apartmentTextField) {
        [self.shippingManager setApartment:self.apartmentTextField.text];
        [GANHelper analyzeEvent:@"apartment_text_changed" label:self.apartmentTextField.text category:ADDRESS_SCREEN];
    }
    
    if (sender == self.commentTextField) {
        if ([self.commentTextField.text isEqualToString:@""]) {
            self.commentIndicatorView.hidden = NO;
        } else {
            self.commentIndicatorView.hidden = YES;
        }
        [self.shippingManager setComment:self.commentTextField.text];
        [GANHelper analyzeEvent:@"comment_text_changed" label:self.apartmentTextField.text category:ADDRESS_SCREEN];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    self.addressSuggestionsTableView.hidden = YES;
    [self.delegate keyboardWillDisappear];
    
    [GANHelper analyzeEvent:@"confirm_pressed" label:[self.shippingManager.selectedAddress formattedAddressString:DBAddressStringModeFull] category:ADDRESS_SCREEN];
    
    return YES;
}

#pragma mark - DBPickerViewDelegate

- (void)db_pickerView:(DBPickerView *)view didSelectRow:(NSString *)row {
    [self.shippingManager setCity:row];
    [self reload];
    
    [GANHelper analyzeEvent:@"city_spinner_selected" label:row category:ADDRESS_SCREEN];
}

- (void)db_componentWillDismiss:(DBPopupViewComponent *)component {
    self.cityTextLabel.text = self.shippingManager.selectedAddress.city;
    
    [GANHelper analyzeEvent:@"city_spinner_closed" category:ADDRESS_SCREEN];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.addressSuggestions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SuggestionCell"];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SuggestionCell"];
        [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0]];
    }
    
    DBShippingAddress *suggestion = self.addressSuggestions[indexPath.row];
    cell.textLabel.text = [suggestion formattedAddressString:DBAddressStringModeShort];
   
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.addressSuggestionsTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.shippingManager selectSuggestion:self.addressSuggestions[indexPath.row]];
    [self reload];
    
    self.addressSuggestions = @[];
    [self.addressSuggestionsTableView reloadData];
    self.addressSuggestionsTableView.hidden = NO;
    
    if (self.keyboardIsHidden) {
        self.addressSuggestionsTableView.hidden = YES;
    }
    
    [GANHelper analyzeEvent:@"autocomplete_list_selected" label:[self.shippingManager.selectedAddress formattedAddressString:DBAddressStringModeFull] category:ADDRESS_SCREEN];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.streetTextField resignFirstResponder];
    [self.apartmentTextField resignFirstResponder];
    [self.commentTextField resignFirstResponder];
    [self.delegate keyboardWillDisappear];
}

@end
