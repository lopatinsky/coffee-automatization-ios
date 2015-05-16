//
//  DBDeliveryViewController.m
//  DoubleB
//
//  Created by Dmitriy Stupivtsev on 10.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBDeliveryViewController.h"
#import "QuartzCore/QuartzCore.h"

@interface DBDeliveryViewController () <UITextFieldDelegate>
@property (weak, nonatomic) UIView *superLayer;
@property (weak, nonatomic) id<DBDeliveryViewControllerDataSource> dataSource;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomToLineConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addressWidthConstraint;

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UITextField *streetTextField;
@property (weak, nonatomic) IBOutlet UITextField *appartmentTextField;

@property (weak, nonatomic) IBOutlet UIView *firstHorizSeparatorView;
@property (weak, nonatomic) IBOutlet UIView *secondHorizSeparatorView;
@property (weak, nonatomic) IBOutlet UIView *thirdHorizSeparatorView;
@property (weak, nonatomic) IBOutlet UIView *verticalSeparatorView;

@property (weak, nonatomic) IBOutlet UIView *streetIndicatorView;
@property (weak, nonatomic) IBOutlet UIView *cityIndicatorView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *indicatorsForTextFields;
@end

@implementation DBDeliveryViewController
UITextField *currentTextField;
CGSize keyboardSize;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getSuperView];
    self.view.backgroundColor = [UIColor db_backgroundColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.addressWidthConstraint.constant = [[UIScreen mainScreen] bounds].size.width;
    self.bottomToLineConstraint.constant = _superLayer.frame.size.height - _thirdHorizSeparatorView.frame.origin.y - 1;
    [self registerForKeyboardNotifications];
    
    [self initLabels];
    [self initTextFields];
    [self initIndicatorsViews];
    [self initSeparatorsViews];
    [self initTableView];
    
    self.indicatorsForTextFields = [NSMutableArray new];
    NSDictionary *cityTF = @{@"textField": _cityTextField,
                             @"indicator": _cityIndicatorView};
    [self.indicatorsForTextFields addObject:cityTF];
    
    NSDictionary *streetTF = @{@"textField": _streetTextField,
                               @"indicator": _streetIndicatorView};
    [self.indicatorsForTextFields addObject:streetTF];
    
    [self hideIndicatorsIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWillBeShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
//    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    if (currentTextField == _streetTextField) {
        CGPoint scrollPoint = CGPointMake(0.0, currentTextField.frame.origin.y);
        [self.scrollView setContentOffset:scrollPoint animated:NO];
        
        return;
    }
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= keyboardSize.height;
    if (!CGRectContainsPoint(aRect, currentTextField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, currentTextField.frame.origin.y - keyboardSize.height);
        [self.scrollView setContentOffset:scrollPoint animated:NO];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)hideIndicatorsIfNeeded {
    for (NSDictionary *dict in _indicatorsForTextFields) {
        [self hideIndicatorForDictionary:dict];
    }
}

- (void)hideIndicatorIfNeededForTextField:(UITextField *)textField {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"textField == %@", textField];
    NSDictionary *dictionary = [[_indicatorsForTextFields filteredArrayUsingPredicate:predicate] firstObject];
    
    [self hideIndicatorForDictionary:dictionary];
}

- (void)hideIndicatorForDictionary:(NSDictionary *)dict {
    if (dict) {
        if ([((UITextField *)dict[@"textField"]).text isEqualToString:@""]) {
            ((UIView *)dict[@"indicator"]).hidden = NO;
        } else {
            ((UIView *)dict[@"indicator"]).hidden = YES;
        }
    }
}

- (void)hideTableViewIfNeeded {
    if (currentTextField == _streetTextField || currentTextField == _appartmentTextField) {
        [self hideTableView:NO];
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
        self.scrollView.contentInset = contentInsets;
        self.scrollView.scrollIndicatorInsets = contentInsets;
        
//        if (currentTextField == _streetTextField) {
            CGPoint scrollPoint = CGPointMake(0.0, currentTextField.frame.origin.y);
            [self.scrollView setContentOffset:scrollPoint animated:NO];
//        }
    } else {
        [self hideTableView:YES];
        [self keyboardWillBeHidden:nil];
    }
}

- (void)hideTableView:(BOOL)toHide {
    if (toHide) {
        self.tableView.hidden = YES;
        self.scrollView.scrollEnabled = YES;
    } else {
        self.tableView.hidden = NO;
        self.scrollView.scrollEnabled = NO;
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    currentTextField = textField;
    [self hideTableViewIfNeeded];
    
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] <= 4.1) {
        
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self hideTableView:YES];
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self hideIndicatorsIfNeeded];
    [self hideTableView:YES];
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    [self hideIndicatorIfNeededForTextField:textField];
//    
//    return YES;
//}

- (void)addToDataSource:(id<DBDeliveryViewControllerDataSource>)dataSource {
    self.dataSource = dataSource;
}

#pragma mark - DBDeliveryViewControllerDataSource

- (void)getSuperView {
    self.superLayer = [_dataSource superView];
}

#pragma mark - initiallizations

- (void)initLabels {
    self.addressLabel.font = [UIFont boldSystemFontOfSize:17.f];
}

- (void)initTextFields {
    self.cityTextField.delegate = self;
    self.streetTextField.delegate = self;
    self.appartmentTextField.delegate = self;
    
    self.cityTextField.font = [UIFont boldSystemFontOfSize:17.f];
    
    currentTextField = _cityTextField;
}

- (void)initIndicatorsViews {
    NSArray *indicators = [NSArray arrayWithObjects:_cityIndicatorView, _streetIndicatorView, nil];
    for (UIView *indicator in indicators) {
        indicator.backgroundColor = [UIColor redColor];
        indicator.layer.cornerRadius = 5.f;
        indicator.layer.masksToBounds = YES;
    }
}

- (void)initSeparatorsViews {
    NSArray *separators = [NSArray arrayWithObjects:_firstHorizSeparatorView, _secondHorizSeparatorView, _thirdHorizSeparatorView, _verticalSeparatorView, nil];
    for (UIView *separator in separators) {
        separator.backgroundColor = [UIColor db_defaultColor];
    }
}

- (void)initTableView {
    self.tableView.backgroundColor = [UIColor db_backgroundColor];
}

@end
