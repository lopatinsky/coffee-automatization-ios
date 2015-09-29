//
//  DBProfileNameModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 17.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBProfileMailModuleView.h"
#import "DBClientInfo.h"

@interface DBProfileMailModuleView ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation DBProfileMailModuleView

- (instancetype)init{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBProfileMailModuleView" owner:self options:nil] firstObject];
    return self;
}

- (void)awakeFromNib{
    [_imageView templateImageWithName:@"e-mail"];
    
    _textField.placeholder = NSLocalizedString(@"Ваш e-mail для получения чеков", nil);
    _textField.keyboardType = UIKeyboardTypeDefault;
    _textField.text = [DBClientInfo sharedInstance].clientMail.value;
    _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    [_textField addTarget:self action:@selector(textFieldDidChangeText:) forControlEvents:UIControlEventEditingChanged];
}

- (void)textFieldDidChangeText:(UITextField *)textField{
    [[DBClientInfo sharedInstance] setMail:textField.text];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if([[DBClientInfo  sharedInstance].clientMail validCharacters:string] || [string isEqualToString:@""]){
        return YES;
    } else {
        return NO;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSString *eventLabel = textField.text;
    [GANHelper analyzeEvent:@"mail_typing" label:eventLabel category:self.analyticsCategory];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSString *eventLabel = textField.text;
    [GANHelper analyzeEvent:@"mail_entered" label:eventLabel category:self.analyticsCategory];
}

@end
