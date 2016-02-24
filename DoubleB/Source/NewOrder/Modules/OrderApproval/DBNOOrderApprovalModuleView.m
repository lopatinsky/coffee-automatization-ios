//
//  DBNOOrderApprovalModuleView.m
//  DoubleB
//
//  Created by Balaban Alexander on 24/02/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBNOOrderApprovalModuleView.h"

#import "OrderCoordinator.h"
#import "DBPickerView.h"

@interface DBNOOrderApprovalModuleView() <DBPopupComponentDelegate, DBPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) DBPickerView *pickerView;

@property (strong, nonatomic) NSArray *choices;

@end

@implementation DBNOOrderApprovalModuleView

+ (NSString *)xibName {
    return @"DBNOOrderApprovalModuleView";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.choices = @[@"через SMS", @"по телефону"];
    
    self.pickerView = [DBPickerView create:DBPickerViewModeItems];
    self.pickerView.pickerDelegate = self;
    self.pickerView.title = NSLocalizedString(@"Подтверждение заказа", nil);
    [self.pickerView configureWithItems:self.choices];
    
    [self.iconImageView templateImageWithName:@"ic_offline_pin_48pt"];
    if ([[OrderCoordinator sharedInstance] orderManager].confirmationType == ConfirmationTypeUndefined) {
        [[OrderCoordinator sharedInstance] orderManager].confirmationType = ConfirmationTypeSms;
    }
    [[OrderCoordinator sharedInstance] addObserver:self withKeyPath:CoordinatorNotificationNewConfirmationType selector:@selector(reload)];
}

- (void)reload:(BOOL)animated {
    [self reloadTitle];
    [super reload:animated];
}

- (void)reloadTitle {
    self.titleLabel.textColor = [UIColor blackColor];
    switch ([[OrderCoordinator sharedInstance] orderManager].confirmationType) {
        case ConfirmationTypePhone: {
            self.titleLabel.text = @"Подтверждение по телефону";
            break;
        }
        case ConfirmationTypeSms: {
            self.titleLabel.text = @"Подтверждение через SMS";
            break;
        }
        case ConfirmationTypeUndefined:
            // ¯\_(ツ)_/¯
            break;
    }
}

- (void)touchAtLocation:(CGPoint)location {
    [self.pickerView showOnView:self.ownerViewController.navigationController.view appearance:DBPopupAppearanceModal transition:DBPopupTransitionBottom];
}

#pragma mark - DBPickerViewDelegate

- (void)db_componentWillDismiss:(DBPopupComponent *)component {
    if (((DBPickerView *)component).selectedIndex == 0) {
        [[OrderCoordinator sharedInstance] orderManager].confirmationType = ConfirmationTypeSms;
    } else if (((DBPickerView *)component).selectedIndex  == 1) {
        [[OrderCoordinator sharedInstance] orderManager].confirmationType = ConfirmationTypePhone;
    }
    [self reload];
}

@end
