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
@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

@implementation DBProfileNameModuleView

- (instancetype)init{
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBProfileNameModuleView" owner:self options:nil] firstObject];
    return self;
}

- (void)awakeFromNib{
    [_imageView templateImageWithName:@"profile_icon"];
    
    _textField.placeholder = NSLocalizedString(@"Имя Фамилия", nil);
    _textField.keyboardType = UIKeyboardTypeDefault;
    _textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    _textField.text = [DBClientInfo sharedInstance].clientName.value;
    _textField.delegate = self;
    
    [_textField addTarget:self action:@selector(textFieldDidChangeText:) forControlEvents:UIControlEventEditingChanged];
    
    self.separatorView.backgroundColor = [UIColor db_separatorColor];
}

- (void)textFieldDidChangeText:(UITextField *)textField{
    [[DBClientInfo sharedInstance] setName:textField.text];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if([[DBClientInfo  sharedInstance].clientName validCharacters:string] || [string isEqualToString:@""]){
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
