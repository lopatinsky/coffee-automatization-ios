//
//  DBPlatiusQRViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 14/02/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBPlatiusQRViewController.h"
#import "DBPlatiusManager.h"
#import "DBPhoneConfirmationView.h"
#import "DBPopupViewController.h"

#import "UIImageView+WebCache.h"

@interface DBPlatiusQRViewController ()<DBPhoneConfirmationViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *barcodeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *barcodeImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *confirmPhoneButton;

@property (strong, nonatomic) DBPhoneConfirmationView *phoneConfirmationView;
@property (strong, nonatomic) DBPopupViewController *popupVC;
@end

@implementation DBPlatiusQRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self db_setTitle:NSLocalizedString(@"Код для оплаты", nil)];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [_confirmPhoneButton addTarget:self action:@selector(confirmPhoneButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_confirmPhoneButton setTitleColor:[UIColor db_defaultColor] forState:UIControlStateNormal];
    
    self.phoneConfirmationView = [DBPhoneConfirmationView create];
    self.phoneConfirmationView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reload];
    if ([DBPlatiusManager sharedInstance].authorized) {
        [self updateStatus:YES];
    } else {
        [_phoneConfirmationView reload];
        self.popupVC = [DBPopupViewController presentView:_phoneConfirmationView inContainer:self.navigationController mode:DBPopupVCAppearanceModeHeader];
    }
}

- (void)reload {
    _titleLabel.text = [DBPlatiusManager sharedInstance].screenAboutDescription;
    
    if ([DBPlatiusManager sharedInstance].authorized) {
         _barcodeLabel.text = [DBPlatiusManager sharedInstance].barcode;
        [_confirmPhoneButton setTitle:NSLocalizedString(@"Сменить телефон", nil) forState:UIControlStateNormal];
    } else {
        _barcodeLabel.text = @"";
        [_confirmPhoneButton setTitle:NSLocalizedString(@"Подтвердить телефон", nil) forState:UIControlStateNormal];
    }
}

- (void)updateStatus:(BOOL)animated {
    if (animated) {
        _barcodeLabel.hidden = YES;
        _barcodeImageView.hidden = YES;
        [_activityIndicator startAnimating];
    }
    
    [[DBPlatiusManager sharedInstance] checkStatus:^(BOOL result) {
        if (result) {
            _barcodeLabel.hidden = NO;
            _barcodeImageView.hidden = NO;
            
            _barcodeLabel.text = [DBPlatiusManager sharedInstance].barcode;
            if ([[DBPlatiusManager sharedInstance] barcodeUrl].length > 0) {
                [_barcodeImageView sd_setImageWithURL:[NSURL URLWithString:[[DBPlatiusManager sharedInstance] barcodeUrl]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    [_activityIndicator stopAnimating];
                }];
            }
        }
    }];
}

- (void)confirmPhoneButtonClick {
    [_phoneConfirmationView reload];
    self.popupVC = [DBPopupViewController presentView:_phoneConfirmationView inContainer:self.navigationController mode:DBPopupVCAppearanceModeHeader];
}

#pragma mark - DBPhoneConfirmationViewDelegate

- (void)db_phoneConfirmationViewConfirmedPhone:(DBPhoneConfirmationView *)view {
    [self reload];
    [self updateStatus:YES];
    
    [self.popupVC dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - DBSettingsProtocol
+ (id<DBSettingsItemProtocol>)settingsItem {
    DBPlatiusQRViewController *vc = [DBPlatiusQRViewController new];
    DBSettingsItem *settingsItem = [DBSettingsItem new];
    
    settingsItem.name = @"platiusBarcodeVC";
    settingsItem.title = NSLocalizedString(@"Код для оплаты", nil);
    settingsItem.iconName = @"promocodes_icon";
    settingsItem.viewController = vc;
    settingsItem.eventLabel = @"platius_barcode_click";
    settingsItem.navigationType = DBSettingsItemNavigationPush;
    
    return settingsItem;
}


@end
