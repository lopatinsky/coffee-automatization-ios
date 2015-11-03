//
//  DBNOProfileModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 15/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBNOProfileModuleView.h"
#import "DBClientInfo.h"

#import "DBProfileViewController.h"

@interface DBNOProfileModuleView ()
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation DBNOProfileModuleView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBNOProfileModuleView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.profileImageView templateImageWithName:@"profile_icon_active"];
    
    [[DBClientInfo sharedInstance] addObserver:self withKeyPaths:@[DBClientInfoNotificationClientName, DBClientInfoNotificationClientPhone, DBClientInfoNotificationClientMail] selector:@selector(reload)];
}

- (void)dealloc {
    [[DBClientInfo sharedInstance] removeObserver:self];
}

- (void)reload:(BOOL)animated {
    [super reload:animated];
    
    if ([DBClientInfo sharedInstance].clientName.valid) {
        if (![DBClientInfo sharedInstance].clientPhone.valid) {
            self.titleLabel.text = NSLocalizedString(@"Укажите, пожалуйста, номер телефона", nil);
            self.titleLabel.textColor = [UIColor db_errorColor];
        } else {
            self.titleLabel.text = [DBClientInfo sharedInstance].clientName.value;
            self.titleLabel.textColor = [UIColor blackColor];
        }
    } else {
        self.titleLabel.text = NSLocalizedString(@"Представьтесь, пожалуйста", nil);
        self.titleLabel.textColor = [UIColor db_errorColor];
    }
}

- (void)touchAtLocation:(CGPoint)location {
    [GANHelper analyzeEvent:@"profile_click" category:self.analyticsCategory];

    DBProfileViewController *profileViewController = [DBProfileViewController new];
    profileViewController.hidesBottomBarWhenPushed = YES;
    profileViewController.analyticsScreen = @"Profile_order_screen";
    [self.ownerViewController.navigationController pushViewController:profileViewController animated:YES];
}

@end
