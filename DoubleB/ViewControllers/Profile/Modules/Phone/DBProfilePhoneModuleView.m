//
//  DBProfileNameModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 17.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBProfilePhoneModuleView.h"
#import "DBClientInfo.h"
#import "AKNumericFormatter.h"
#import "UITextField+AKNumericFormatter.h"

@interface DBProfilePhoneModuleView ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

@implementation DBProfilePhoneModuleView

- (instancetype)init{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBProfilePhoneModuleView" owner:self options:nil] firstObject];
    return self;
}

- (void)awakeFromNib{
    [_imageView templateImageWithName:@"phone_icon"];
    
    _textField.placeholder = NSLocalizedString(@"Контактный номер телефона", nil);
    _textField.keyboardType = UIKeyboardTypePhonePad;
    _textField.text = [DBClientInfo sharedInstance].clientPhone.value;
    _textField.delegate = self;
    
    NSString *mask = @"+* (***) ***-**-**";
    
    _textField.text = [AKNumericFormatter formatString:[DBClientInfo sharedInstance].clientPhone.value usingMask:mask placeholderCharacter:'*'];
    _textField.numericFormatter = [AKNumericFormatter formatterWithMask:mask placeholderCharacter:'*'];
    
    [_textField addTarget:self action:@selector(textFieldDidChangeText:) forControlEvents:UIControlEventEditingChanged];
    
    self.separatorView.backgroundColor = [UIColor db_separatorColor];
}

- (void)saveValue {
    NSString *phoneText = self.textField.text;
    
    NSMutableCharacterSet *nonDigitsSet = [NSMutableCharacterSet decimalDigitCharacterSet];
    [nonDigitsSet invert];
    
    NSString *validText = [[phoneText componentsSeparatedByCharactersInSet:nonDigitsSet] componentsJoinedByString:@""];
    [[DBClientInfo sharedInstance] setPhone:validText];
}

- (void)textFieldDidChangeText:(UITextField *)textField{
    [self saveValue];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if([[DBClientInfo  sharedInstance].clientPhone validCharacters:string] || [string isEqualToString:@""]){
        return YES;
    } else {
        return NO;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if([textField.text isEqualToString:@""] || [textField.text isEqualToString:@"+"]) {
        textField.text = @"+7";
        [self saveValue];
    }
    
    NSString *eventLabel = textField.text;
    [GANHelper analyzeEvent:@"phone_typing" label:eventLabel category:self.analyticsCategory];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSString *eventLabel = textField.text;
    [GANHelper analyzeEvent:@"phone_entered" label:eventLabel category:self.analyticsCategory];
}

@end
