//
//  DBVenueStartSelectionSettingsView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 27/02/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBVenueStartSelectionSettingsView.h"

#import "DBUserDefaultsManager.h"

#import "UIControl+BlocksKit.h"

@interface DBVenueStartSelectionSettingsView ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *switchView;

@end

@implementation DBVenueStartSelectionSettingsView

+ (DBVenueStartSelectionSettingsView *)create {
    DBVenueStartSelectionSettingsView *view = [[[NSBundle mainBundle] loadNibNamed:@"DBVenueStartSelectionSettingsView" owner:self options:nil] firstObject];
    
    return view;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.switchView.onTintColor = [UIColor db_defaultColor];
    self.switchView.on = ![DBUserDefaultsManager sharedInstance].showVenuesPopupOnStart;
    [self.switchView bk_addEventHandler:^(id sender) {
        [DBUserDefaultsManager sharedInstance].showVenuesPopupOnStart = !self.switchView.isOn;
    } forControlEvents:UIControlEventValueChanged];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    self.titleLabel.text = _title;
}

- (CGFloat)db_popupContentContentHeight {
    return 100;
}

@end
