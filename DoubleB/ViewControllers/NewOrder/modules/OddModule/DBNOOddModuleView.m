//
//  DBNOOddModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 04/12/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBNOOddModuleView.h"
#import "OrderCoordinator.h"
#import "DBNOOddPopupView.h"
#import "OrderCoordinator.h"

#import "UIAlertView+BlocksKit.h"

@interface DBNOOddModuleView () <DBPopupComponentDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) DBNOOddPopupView *popupView;
@end

@implementation DBNOOddModuleView

+ (NSString *)xibName {
    return @"DBNOOddModuleView";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.iconImageView templateImageWithName:@"coins_icon"];
    
    self.popupView = [DBNOOddPopupView new];
    self.popupView.placeholder = NSLocalizedString(@"Нужна сдача с", nil);
    self.popupView.keyboardType = UIKeyboardTypeDecimalPad;
    self.popupView.delegate = self;
    
    [self reloadTitle];
}

- (void)reload:(BOOL)animated {
    [self reloadTitle];
    [super reload:animated];
}

- (void)reloadTitle {
    if ([OrderCoordinator sharedInstance].orderManager.oddSum.length == 0) {
        self.titleLabel.textColor = [UIColor db_grayColor];
        self.titleLabel.text = NSLocalizedString(@"Нужна сдача с", nil);
    } else {
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.text = [NSString stringWithFormat:@"%@ %@ %@", NSLocalizedString(@"Нужна сдача с", nil), [OrderCoordinator sharedInstance].orderManager.oddSum, [Compatibility currencySymbol]];
    };
}

- (void)db_componentWillDismiss:(DBPopupComponent *)component {
    [OrderCoordinator sharedInstance].orderManager.oddSum = self.popupView.text;
    [self reloadTitle];
}

- (void)touchAtLocation:(CGPoint)location {
    if ([self.delegate respondsToSelector:@selector(db_moduleViewModalComponentContainer:)]) {
        self.popupView.text = [OrderCoordinator sharedInstance].orderManager.oddSum;
        [self.popupView showFrom:self onView:[self.delegate db_moduleViewModalComponentContainer:self]];
    }
}

- (CGFloat)moduleViewContentHeight {
    if ([OrderCoordinator sharedInstance].orderManager.paymentType == PaymentTypeCash) {
        return 45.f;
    } else {
        self.titleLabel.text = @"";
        return 0.f;
    }
}

@end
