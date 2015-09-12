//
//  DBProfileNameModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 14.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import "DBProfileTextModuleView.h"

@interface DBProfileTextModuleView ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation DBProfileTextModuleView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBProfileTextModuleView" owner:self options:nil] firstObject];
    return self;
}

- (void)awakeFromNib{
    [self.textField addTarget:self
                       action:@selector(textFieldDidChangeText:)
             forControlEvents:UIControlEventEditingChanged];
}

- (void)setModuleImage:(UIImage *)moduleImage{
    _moduleImage = moduleImage;
    [_imageView templateImage:_moduleImage];
}

- (void)setText:(NSString *)text{
    _text = text;
    _textField.text = _text;
}

- (void)setTextPlaceholder:(NSString *)textPlaceholder{
    _textPlaceholder = textPlaceholder;
    _textField.placeholder = _textPlaceholder;
}


- (void)textFieldDidChangeText:(UITextField *)textField{
    _text = textField.text;
}


@end
