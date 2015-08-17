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

@end

@implementation DBProfilePhoneModuleView

- (instancetype)init{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBProfilePhoneModuleView" owner:self options:nil] firstObject];
    return self;
}

- (void)awakeFromNib{
    [_imageView templateImageWithName:@"phone"];
    
    _textField.placeholder = NSLocalizedString(@"Контактный номер телефона", nil);
    _textField.keyboardType = UIKeyboardTypePhonePad;
    _textField.text = [DBClientInfo sharedInstance].clientPhone;
    _textField.delegate = self;
    
    NSString *mask = @"+* (***) ***-**-**";
    
    _textField.text = [AKNumericFormatter formatString:[DBClientInfo sharedInstance].clientPhone usingMask:mask placeholderCharacter:'*'];
    _textField.numericFormatter = [AKNumericFormatter formatterWithMask:mask placeholderCharacter:'*'];
    
    [_textField addTarget:self action:@selector(textFieldDidChangeText:) forControlEvents:UIControlEventEditingChanged];
}

- (void)textFieldDidChangeText:(UITextField *)textField{
    [DBClientInfo sharedInstance].clientPhone = textField.text;
    
    if([self.delegate respondsToSelector:@selector(db_profileModuleDidChange:)]){
        [self.delegate db_profileModuleDidChange:self];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if([[DBClientInfo  sharedInstance] validPhoneCharacters:string] || [string isEqualToString:@""]){
        return YES;
    } else {
        return NO;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if([textField.text isEqualToString:@""] || [textField.text isEqualToString:@"+"])
        textField.text = @"+7";
    
    NSString *eventLabel = textField.text;
    [GANHelper analyzeEvent:@"mail_typing" label:eventLabel category:self.analyticsCategory];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSString *eventLabel = textField.text;
    [GANHelper analyzeEvent:@"mail_entered" label:eventLabel category:self.analyticsCategory];
}

@end
