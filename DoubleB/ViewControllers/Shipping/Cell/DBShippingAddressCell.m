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

@property (weak, nonatomic) IBOutlet UIButton *imageButton;
@property (weak, nonatomic) IBOutlet UIImageView *anyImageView;

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
    
    [self.imageButton addTarget:self action:@selector(imageButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.imageButton.hidden = YES;
    
    [self.anyImageView templateImageWithName:@"close_circle_icon" tintColor:[UIColor db_grayColor]];
    self.anyImageView.hidden = YES;
}

- (void)configureWithType:(DBShippingAddressCellType)type {
    _type = type;
    
    self.anyImageView.hidden = YES;
    self.imageButton.hidden = YES;
    self.textField.userInteractionEnabled = YES;
    
    switch (_type) {
        case DBShippingAddressCellTypeCity:{
            self.titleLabel.text = NSLocalizedString(@"Город", nil);
            self.textField.userInteractionEnabled = NO;
            self.textField.text = _shippingManager.selectedAddress.city;
        }
            break;
        case DBShippingAddressCellTypeStreet:{
            self.titleLabel.text = NSLocalizedString(@"Улица", nil);
            self.textField.text = _shippingManager.selectedAddress.street;
        }
            break;
        case DBShippingAddressCellTypeHome:{
            self.titleLabel.text = NSLocalizedString(@"Дом", nil);
            self.textField.text = _shippingManager.selectedAddress.home;
        }
            break;
        case DBShippingAddressCellTypeApartment:{
            self.titleLabel.text = NSLocalizedString(@"Квартира", nil);
            self.textField.text = _shippingManager.selectedAddress.apartment;
        }
            break;
        case DBShippingAddressCellTypeComment:{
            self.titleLabel.text = NSLocalizedString(@"Комментарий", nil);
            self.textField.text = _shippingManager.selectedAddress.comment;
        }
            break;
            
        default:
            break;
    }
}

- (void)setImageViewVisisble:(BOOL)imageViewVisisble {
    _imageViewVisisble = imageViewVisisble;
    
    self.anyImageView.hidden = !_imageViewVisisble;
    self.imageButton.hidden = !_imageViewVisisble;
}

- (void)imageButtonClick {
    if ([self.delegate respondsToSelector:@selector(db_addressCellClickedAtImage:)]) {
        [self.delegate db_addressCellClickedAtImage:self];
    }
    
    self.textField.text = @"";
}

- (void)textFieldDidChange:(UITextField *)sender {
    switch (_type) {
        case DBShippingAddressCellTypeStreet:
            [_shippingManager setStreet:sender.text];
            break;
        case DBShippingAddressCellTypeHome:
            [_shippingManager setHome:sender.text];
            break;
        case DBShippingAddressCellTypeApartment:
            [_shippingManager setApartment:sender.text];
            break;
        case DBShippingAddressCellTypeComment:
            [_shippingManager setComment:sender.text];
            break;
            
        default:
            break;
    }
    
    if ([self.delegate respondsToSelector:@selector(db_addressCell:textChanged:)]) {
        [self.delegate db_addressCell:self textChanged:sender.text];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.anyImageView.hidden = NO;
    self.imageButton.hidden = NO;
    
    if ([self.delegate respondsToSelector:@selector(db_addressCellStartEditing:)]) {
        [self.delegate db_addressCellStartEditing:self];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.anyImageView.hidden = YES;
    self.imageButton.hidden = YES;
}

@end
