//
//  DBGiftRecipientDataModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 19/09/15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBFGRecipientModuleView.h"
#import "DBFriendGiftHelper.h"

#import "AKNumericFormatter.h"
#import "UITextField+AKNumericFormatter.h"
#import "UIViewController+DBPeoplePickerController.h"
#import "DBModuleHeaderView.h"

NSString *const kDBFGRecipientModuleViewDismiss = @"kDBFGRecipientModuleViewDismiss";

@interface DBFGRecipientModuleView ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *profileLabel;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (strong, nonatomic) IBOutlet UITextField *phoneTextField;

@property (weak, nonatomic) IBOutlet UIImageView *contactsImageView;
@property (weak, nonatomic) IBOutlet UIButton *contactsButton;

@end

@implementation DBFGRecipientModuleView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBFGRecipientModuleView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialize name
    self.profileLabel.text = NSLocalizedString(@"ФИО", nil);
    
    self.nameTextField.placeholder = NSLocalizedString(@"Имя Фамилия", nil);
    self.nameTextField.keyboardType = UIKeyboardTypeDefault;
    self.nameTextField.delegate = self;
    [self.nameTextField addTarget:self action:@selector(textFieldDidChangeText:) forControlEvents:UIControlEventEditingChanged];
    
    // Initialize phone
    self.phoneLabel.text = NSLocalizedString(@"Телефон", nil);
    
    self.phoneTextField.placeholder = NSLocalizedString(@"Контактный номер телефона", nil);
    self.phoneTextField.keyboardType = UIKeyboardTypePhonePad;
    self.phoneTextField.delegate = self;
    self.phoneTextField.numericFormatter = [AKNumericFormatter formatterWithMask:@"+* (***) ***-**-**" placeholderCharacter:'*'];
    [self.phoneTextField addTarget:self action:@selector(textFieldDidChangeText:) forControlEvents:UIControlEventEditingChanged];
    
    // Initialize contacts button
    [self.contactsImageView templateImageWithName:@"contacts_icon"];
    [self.contactsButton addTarget:self action:@selector(clickContactsButton) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissAll) name:kDBFGRecipientModuleViewDismiss object:nil];
    
    UIToolbar *keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Готово", nil)
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(dismissAll)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    self.nameTextField.inputAccessoryView = keyboardDoneButtonView;
    self.phoneTextField.inputAccessoryView = keyboardDoneButtonView;
}

- (void)viewWillDissapearFromVC {
    [self dismissAll];
}

- (void)dismissAll {
    [self.nameTextField resignFirstResponder];
    [self.phoneTextField resignFirstResponder];
}

- (void)reload:(BOOL)animated {
    [super reload:animated];
    
    self.nameTextField.text = [DBFriendGiftHelper sharedInstance].friendName.value;
    self.phoneTextField.text = [AKNumericFormatter formatString:[DBFriendGiftHelper sharedInstance].friendPhone.value usingMask:@"+* (***) ***-**-**" placeholderCharacter:'*'];
}

- (void)clickContactsButton {
    [self dismissAll];
    [self.ownerViewController db_presentPeoplePickerController:^(DBProcessState state, NSString *name, NSString *phone) {
        if (state == DBProcessStateDone) {
            [DBFriendGiftHelper sharedInstance].friendName.value = name;
            
            [self setValidTextToPhone:phone];
            [self.ownerViewController reloadAllModules];
            
            [GANHelper analyzeEvent:@"friend_contact_selected"
                              label:[NSString stringWithFormat:@"%@,%@", name, phone]
                           category:self.analyticsCategory];
        } else {
            [GANHelper analyzeEvent:@"friend_contact_cancelled" category:self.analyticsCategory];
        }
    }];
}

- (void)textFieldDidChangeText:(UITextField *)textField {
    if (textField == self.nameTextField) {
        [DBFriendGiftHelper sharedInstance].friendName.value = textField.text;
    } else {
        [self setValidTextToPhone:self.phoneTextField.text];
    }
}

- (void)setValidTextToPhone:(NSString *)formattedPhone {
    NSString *phoneText = formattedPhone;
    NSMutableCharacterSet *nonDigitsSet = [NSMutableCharacterSet decimalDigitCharacterSet];
    [nonDigitsSet invert];
    
    NSString *validText = [[phoneText componentsSeparatedByCharactersInSet:nonDigitsSet] componentsJoinedByString:@""];
    [DBFriendGiftHelper sharedInstance].friendPhone.value = validText;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    BOOL result = YES;
    if(textField == self.nameTextField){
        result = result && [[DBFriendGiftHelper sharedInstance].friendName validCharacters:string];
    }
    if(textField == self.phoneTextField){
        result = result && [[DBFriendGiftHelper sharedInstance].friendPhone validCharacters:string];
    }
    return result;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField == self.phoneTextField) {
        if([textField.text isEqualToString:@""] || [textField.text isEqualToString:@"+"])
            textField.text = @"+7";
        
        [GANHelper analyzeEvent:@"gift_start_typing" label:@"friend_gift_phone" category:self.analyticsCategory];
    }
    
    if(textField == self.nameTextField){
        [GANHelper analyzeEvent:@"gift_start_typing" label:@"friend_gift_name" category:self.analyticsCategory];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if(textField == self.nameTextField){
        [GANHelper analyzeEvent:@"friend_gift_name_entered" label:textField.text category:self.analyticsCategory];
    }
    
    if(textField == self.phoneTextField) {
        [GANHelper analyzeEvent:@"friend_gift_phone_entered" label:textField.text category:self.analyticsCategory];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.returnKeyType == UIReturnKeyNext) {
        [self.phoneTextField becomeFirstResponder];
    }
    return YES;
}


@end
