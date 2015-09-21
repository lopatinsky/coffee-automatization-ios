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

@interface DBFGRecipientModuleView ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UIImageView *phoneImageView;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;

@property (weak, nonatomic) IBOutlet UIImageView *contactsImageView;
@property (weak, nonatomic) IBOutlet UIButton *contactsButton;

@property (weak, nonatomic) IBOutlet UIView *middleSeparatorView;
@property (weak, nonatomic) IBOutlet UIView *bottomSeparatorView;

@end

@implementation DBFGRecipientModuleView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBFGRecipientModuleView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    // Initialize name
    [self.profileImageView templateImageWithName:@"profile"];
    
    self.nameTextField.placeholder = NSLocalizedString(@"Имя Фамилия", nil);
    self.nameTextField.keyboardType = UIKeyboardTypeDefault;
    self.nameTextField.delegate = self;
    [self.nameTextField addTarget:self action:@selector(textFieldDidChangeText:) forControlEvents:UIControlEventEditingChanged];
    
    // Initialize phone
    [self.phoneImageView templateImageWithName:@"phone"];
    
    self.phoneTextField.placeholder = NSLocalizedString(@"Контактный номер телефона", nil);
    self.phoneTextField.keyboardType = UIKeyboardTypePhonePad;
    self.phoneTextField.delegate = self;
    self.phoneTextField.numericFormatter = [AKNumericFormatter formatterWithMask:@"+* (***) ***-**-**" placeholderCharacter:'*'];
    [self.phoneTextField addTarget:self action:@selector(textFieldDidChangeText:) forControlEvents:UIControlEventEditingChanged];
    
    // Initialize separators
    self.middleSeparatorView.backgroundColor = [UIColor db_separatorColor];
    self.bottomSeparatorView.backgroundColor = [UIColor db_separatorColor];
    
    // Initialize contacts button
    [self.contactsImageView templateImageWithName:@"contacts_icon"];
    [self.contactsButton addTarget:self action:@selector(clickContactsButton) forControlEvents:UIControlEventTouchUpInside];
}

- (void)reload {
    [super reload];
    
    self.nameTextField.text = [DBFriendGiftHelper sharedInstance].friendName.value;
    self.phoneTextField.text = [AKNumericFormatter formatString:[DBFriendGiftHelper sharedInstance].friendPhone.value usingMask:@"+* (***) ***-**-**" placeholderCharacter:'*'];
    
}

- (void)clickContactsButton {
    [self.ownerViewController db_presentPeoplePickerController:^(DBProcessState state, NSString *name, NSString *phone) {
        if(state == DBProcessStateDone){
            [DBFriendGiftHelper sharedInstance].friendName.value = name;
            [DBFriendGiftHelper sharedInstance].friendPhone.value = phone;
            
            [GANHelper analyzeEvent:@"friend_contact_selected"
                              label:[NSString stringWithFormat:@"%@,%@", name, phone]
                           category:self.analyticsCategory];
        } else {
            [GANHelper analyzeEvent:@"friend_contact_cancelled" category:self.analyticsCategory];
        }
    }];
}

- (void)textFieldDidChangeText:(UITextField *)textField{
    if(textField == self.nameTextField) {
        [DBFriendGiftHelper sharedInstance].friendName.value = textField.text;
    } else {
        [DBFriendGiftHelper sharedInstance].friendPhone.value = textField.text;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    BOOL result = [string isEqualToString:@""];
    if(textField == self.nameTextField){
        result = result && [[DBFriendGiftHelper sharedInstance].friendName validCharacters:string];
    }
    if(textField == self.phoneTextField){
        result = result && [[DBFriendGiftHelper sharedInstance].friendPhone validCharacters:string];
    }
    return result;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if(textField == self.phoneTextField){
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


@end
