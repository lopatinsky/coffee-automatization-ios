//
//  DBProfileNameModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 17.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBProfileNameModuleView.h"
#import "DBClientInfo.h"

@interface DBProfileNameModuleView ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation DBProfileNameModuleView

- (instancetype)init{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBProfileNameModuleView" owner:self options:nil] firstObject];
    return self;
}

- (void)awakeFromNib{
    [_imageView templateImageWithName:@"profile"];
    
    _textField.placeholder = NSLocalizedString(@"Имя Фамилия", nil);
    _textField.keyboardType = UIKeyboardTypeDefault;
    _textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    _textField.text = [DBClientInfo sharedInstance].clientName;
    _textField.delegate = self;
    
    [_textField addTarget:self action:@selector(textFieldDidChangeText:) forControlEvents:UIControlEventEditingChanged];
}

- (void)textFieldDidChangeText:(UITextField *)textField{
    [DBClientInfo sharedInstance].clientName = textField.text;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if([[DBClientInfo  sharedInstance] validNameCharacters:string] || [string isEqualToString:@""]){
        return YES;
    } else {
        return NO;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSString *eventLabel = textField.text;
    [GANHelper analyzeEvent:@"name_typing" label:eventLabel category:self.analyticsCategory];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSString *eventLabel = textField.text;
    [GANHelper analyzeEvent:@"name_entered" label:eventLabel category:self.analyticsCategory];
}

@end
