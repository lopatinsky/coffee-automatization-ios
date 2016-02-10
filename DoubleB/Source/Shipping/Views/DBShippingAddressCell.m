//
//  DBShippingAddressCell.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 22/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBShippingAddressCell.h"

#import "OrderCoordinator.h"

@interface DBShippingAddressCell ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (strong, nonatomic) ShippingManager *shippingManager;

@end

@implementation DBShippingAddressCell

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBShippingAddressCell" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    self.shippingManager = [OrderCoordinator sharedInstance].shippingManager;
    self.textField.delegate = self;
    [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)configureWithType:(DBAddressAttribute)type {
    _type = type;
    self.textField.userInteractionEnabled = YES;
    
    NSString *title = @"";
    switch (_type) {
        case DBAddressAttributeCity:{
            title = NSLocalizedString(@"Город", nil);
            self.textField.userInteractionEnabled = NO;
            self.textField.text = _shippingManager.selectedAddress.city;
        }
            break;
        case DBAddressAttributeStreet:{
            title = NSLocalizedString(@"Улица", nil);
            self.textField.text = _shippingManager.selectedAddress.street;
        }
            break;
        case DBAddressAttributeHome:{
            title = NSLocalizedString(@"Дом", nil);
            self.textField.text = _shippingManager.selectedAddress.home;
        }
            break;
        case DBAddressAttributeApartment:{
            title = NSLocalizedString(@"Квартира", nil);
            self.textField.text = _shippingManager.selectedAddress.apartment;
        }
            break;
        case DBAddressAttributeEntranceNumber:{
            title = NSLocalizedString(@"Подъезд", nil);
            self.textField.text = _shippingManager.selectedAddress.entranceNumber;
            break;
        }
        case DBAddressAttributeComment:{
            title = NSLocalizedString(@"Комментарий", nil);
            self.textField.text = _shippingManager.selectedAddress.comment;
        }
            break;
            
        default:
            break;
    }
    
    if ([DBShippingAddress required:_type]){
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@*", title]];
        [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(title.length, 1)];
        self.titleLabel.attributedText = attrString;
    } else {
        self.titleLabel.text = title;
    }
}

- (void)setEditingEnabled:(BOOL)editingEnabled {
    _editingEnabled = editingEnabled;
    
    if (_editingEnabled) {
        self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    } else {
        self.textField.clearButtonMode = UITextFieldViewModeNever;
    }
}

- (void)textFieldDidChange:(UITextField *)sender {
    switch (_type) {
        case DBAddressAttributeStreet:
            [_shippingManager setStreet:sender.text];
            break;
        case DBAddressAttributeHome:
            [_shippingManager setHome:sender.text];
            break;
        case DBAddressAttributeApartment:
            [_shippingManager setApartment:sender.text];
            break;
        case DBAddressAttributeComment:
            [_shippingManager setComment:sender.text];
            break;
        case DBAddressAttributeEntranceNumber:
            [_shippingManager setEntranceNumber:sender.text];
            break;
        default:
            break;
    }
    
    if ([self.delegate respondsToSelector:@selector(db_addressCell:textChanged:)]) {
        [self.delegate db_addressCell:self textChanged:sender.text];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(db_addressCellStartEditing:)]) {
        [self.delegate db_addressCellStartEditing:self];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(db_addressCellEndEditing:)]) {
        [self.delegate db_addressCellEndEditing:self];
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(db_addressCellShouldClear:)]) {
        return [self.delegate db_addressCellShouldClear:self];
    } else {
        return NO;
    }
}

@end
