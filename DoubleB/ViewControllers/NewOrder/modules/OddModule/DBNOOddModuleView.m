//
//  DBNOOddModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 04/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBNOOddModuleView.h"
#import "OrderCoordinator.h"

#import "UIAlertView+BlocksKit.h"

@interface DBNOOddModuleView () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation DBNOOddModuleView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBNOOddModuleView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.iconImageView templateImageWithName:@"coins_icon"];
    
    self.textField.placeholder = NSLocalizedString(@"Нужна сдача с", nil);
    self.textField.delegate = self;
    [self.textField addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
}

- (void)reload:(BOOL)animated {
    [super reload:animated];
    
    self.textField.text = [OrderCoordinator sharedInstance].orderManager.oddSum;
}

- (void)textFieldDidChange {
    [OrderCoordinator sharedInstance].orderManager.oddSum = self.textField.text;
}

//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Save"
//                                                        message:@"Enter File Name"
//                                                       delegate:self
//                                              cancelButtonTitle:@"Cancel"
//                                              otherButtonTitles:@"OK", nil];
//    
//    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
//    
//    [alertView show];
//
//    
//    return NO;
//}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.textField resignFirstResponder];
    return YES;
}

@end
