//
//  DBProfileViewController.m
//  DoubleB
//
//  Created by Balaban Alexander on 01/08/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBProfileViewController.h"
#import "UIColor+Brandbook.h"
#import "AKNumericFormatter.h"
#import "UITextField+AKNumericFormatter.h"
#import "UIBarButtonItem+BlocksKit.h"
#import "DBAPIClient.h"
#import "IHSecureStore.h"
#import "DBProfileCell.h"
#import "DBClientInfo.h"


@interface DBProfileViewController () <UITextFieldDelegate>
@property (strong, nonatomic) DBProfileCell *profileCellName;
@property (strong, nonatomic) DBProfileCell *profileCellPhone;
@property (strong, nonatomic) DBProfileCell *profileCellMail;
@end

@implementation DBProfileViewController {
    AKNumericFormatter *_formatter;

    UITextField *currentEditingTextField;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Профиль", nil);
    
    self.tableView.rowHeight = 50;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.backgroundColor = [UIColor db_backgroundColor];
    self.tableView.tableFooterView = [UIView new];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [GANHelper analyzeScreen:self.screen];

    if (self.fillingMode == ProfileFillingModeFillToContinue) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemCancel handler:^(id sender) {
            [self sendProfileInfo];
            [self.view endEditing:YES];
            [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
        }];
    }

    [self reloadDoneButton];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self sendProfileInfo];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (!parent) {
        NSString *eventLabel = [NSString stringWithFormat:@"%@,%@,%@",
                                [DBClientInfo sharedInstance].clientName,
                                [DBClientInfo sharedInstance].clientPhone,
                                [DBClientInfo sharedInstance].clientMail];
        
        if([self.screen isEqualToString:@"Profile_screen"]){
            [GANHelper analyzeEvent:@"back_settings_click"
                              label:eventLabel
                           category:self.screen];
        } else {
            [GANHelper analyzeEvent:@"back_order_click"
                              label:eventLabel
                           category:self.screen];
        }
    }
}



#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DBProfileCell *cell = (DBProfileCell *)[tableView dequeueReusableCellWithIdentifier:@"ProfileCell"];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ProfileCell" owner:self options:nil] firstObject];
        switch (indexPath.row) {
            case 0:
                self.profileCellName = cell;
                break;
            case 1:
                self.profileCellPhone = cell;
                break;
            case 2:
                self.profileCellMail = cell;
                break;
            default:
                break;
        }
    }
    
    cell.profileCellTextField.delegate = self;
    
    switch (indexPath.row) {
        case 0: {
            [cell.profileCellIcon templateImageWithName:@"profile"];
            cell.profileCellTextField.placeholder = NSLocalizedString(@"Имя Фамилия", nil);
            cell.profileCellTextField.keyboardType = UIKeyboardTypeDefault;
            cell.profileCellTextField.returnKeyType = UIReturnKeyNext;
            cell.profileCellTextField.text = [DBClientInfo sharedInstance].clientName;
            break;
        }
        case 1: {
            [cell.profileCellIcon templateImageWithName:@"phone"];
            cell.profileCellTextField.placeholder = NSLocalizedString(@"Контактный номер телефона", nil);
            cell.profileCellTextField.keyboardType = UIKeyboardTypePhonePad;
            cell.profileCellTextField.returnKeyType = UIReturnKeyNext;
            cell.profileCellTextField.text = [DBClientInfo sharedInstance].clientPhone;
            break;
        }
        case 2: {
            [cell.profileCellIcon templateImageWithName:@"e-mail"];
            cell.profileCellTextField.placeholder = NSLocalizedString(@"Ваш e-mail для получения чеков", nil);
            cell.profileCellTextField.keyboardType = UIKeyboardTypeDefault;
            cell.profileCellTextField.returnKeyType = UIReturnKeyDone;
            cell.profileCellTextField.text = [DBClientInfo sharedInstance].clientMail;
            cell.profileCellTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            break;
        }
        default:
            break;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    currentEditingTextField = textField;
    
    int index = [self indexPathRowForTextField:textField];
    
    if(index == 0){
        [GANHelper analyzeEvent:@"start_typing" label:@"name" category:self.screen];
    }
    
    if(index == 1){
        if([textField.text isEqualToString:@""])
            textField.text = @"+7";
        [GANHelper analyzeEvent:@"start_typing" label:@"phone" category:self.screen];
    }
    
    if(index == 2){
        [GANHelper analyzeEvent:@"start_typing" label:@"mail" category:self.screen];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [self sendProfileInfo];
    
    NSString *eventLabel = [textField.text isEqualToString:@""] ? @"null" : textField.text;
    int index = [self indexPathRowForTextField:textField];
    
    if(index == 0){
        [GANHelper analyzeEvent:@"name_entered" label:eventLabel category:self.screen];
    }
    
    if(index == 1) {
        [GANHelper analyzeEvent:@"phone_entered" label:eventLabel category:self.screen];
    }
    
    if(index == 2) {
        [GANHelper analyzeEvent:@"mail_entered" label:eventLabel category:self.screen];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL result = NO;
    
    if([self validSubString:string forTextField:textField] || [string isEqualToString:@""]){
        NSMutableString *currentText = [[NSMutableString alloc] initWithString:textField.text];
        [currentText replaceCharactersInRange:range withString:string];
        [self setString:currentText forTextField:textField];
        
        if([self dataIsValid]){
            [self showRightBarButtonItem];
        } else {
            [self hideRightBarButtonItem];
        }
        
        result = YES;
    }
    
    return result;
}

#pragma mark - other methods

- (void)sendProfileInfo{
    [GANHelper trackClientInfo];
    
    NSString *clientId = [[IHSecureStore sharedInstance] clientId];
    
    if(clientId){
    [[DBAPIClient sharedClient] POST:@"client"
                          parameters:@{@"client_id": clientId,
                                       @"client_name": [DBClientInfo sharedInstance].clientName,
                                       @"client_phone": [DBClientInfo sharedInstance].clientPhone,
                                       @"client_email": [DBClientInfo sharedInstance].clientMail}
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 //NSLog(@"%@", responseObject);
                             }
                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 NSLog(@"%@", error);
                             }];
    }
}

- (BOOL)dataIsValid {
    BOOL result = self.fillingMode == ProfileFillingModeFillToContinue;
    result = result && [[DBClientInfo sharedInstance] validClientName];
    result = result && [[DBClientInfo sharedInstance] validClientPhone];
    
    return result;
}

- (void)reloadDoneButton {
    if ([self dataIsValid]) {
        [self showRightBarButtonItem];
    } else {
        [self hideRightBarButtonItem];
    }
}

- (void)showRightBarButtonItem{
    if(!self.navigationItem.rightBarButtonItem && self.fillingMode == ProfileFillingModeFillToContinue){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemDone handler:^(id sender) {
            if (![self dataIsValid])
                return;
            [self sendProfileInfo];
            [self.view endEditing:YES];
            if ([self.delegate respondsToSelector:@selector(profileViewControllerDidFillAllFields:)])
                [self.delegate profileViewControllerDidFillAllFields:self];
        }];
    }
}

- (void)hideRightBarButtonItem{
    self.navigationItem.rightBarButtonItem = nil;
}

- (BOOL)validSubString:(NSString *)string forTextField:(UITextField *)textField{
    int index = [self indexPathRowForTextField:textField];
    
    switch (index) {
        case 0:
            return [[DBClientInfo sharedInstance] validNameCharacters:string];
            break;
        case 1:
            return [[DBClientInfo sharedInstance] validPhoneCharacters:string];
            break;
        case 2:
            return [[DBClientInfo sharedInstance] validMailCharacters:string];
            break;
    }
    
    return NO;
}

- (void)setString:(NSString *)string forTextField:(UITextField *)textField{
    int index = [self indexPathRowForTextField:textField];
    
    switch (index) {
        case 0:
            [DBClientInfo sharedInstance].clientName = string;
            break;
        case 1:
            [DBClientInfo sharedInstance].clientPhone = string;
            break;
        case 2:
            [DBClientInfo sharedInstance].clientMail = string;
            break;
    }
}

- (int)indexPathRowForTextField:(UITextField *)textField{
    if(textField == self.profileCellName.profileCellTextField){
        return 0;
    }
    
    if(textField == self.profileCellPhone.profileCellTextField){
        return 1;
    }
    
    if(textField == self.profileCellMail.profileCellTextField){
        return 2;
    }
    
    return -1;
}

@end
