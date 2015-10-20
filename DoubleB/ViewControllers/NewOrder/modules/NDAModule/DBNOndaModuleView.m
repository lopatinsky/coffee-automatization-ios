//
//  DBNOndaModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 17/10/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBNOndaModuleView.h"
#import "DBHTMLViewController.h"

#import "DBCompanyInfo.h"

#import <BlocksKit/UIControl+BlocksKit.h>

@interface DBNOndaModuleView ()
@property (weak, nonatomic) IBOutlet UILabel *labelNda;
@property (weak, nonatomic) IBOutlet UISwitch *ndaAcceptSwitch;
@end

@implementation DBNOndaModuleView

- (instancetype)init {
    self = [[[NSBundle mainBundle] loadNibNamed:@"DBNOndaModuleView" owner:self options:nil] firstObject];
    
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
    self.labelNda.text = NSLocalizedString(@"Согласен с Правилами оплаты", nil);
    [self reload];
    self.ndaAcceptSwitch.onTintColor = [UIColor db_defaultColor];
    
    @weakify(self)
    [self.ndaAcceptSwitch bk_addEventHandler:^(id sender) {
        @strongify(self)
        
        BOOL ndaSigned = self.ndaAcceptSwitch.isOn;
        
        [[NSUserDefaults standardUserDefaults] setBool:ndaSigned forKey:kDBDefaultsNDASigned];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if (ndaSigned) {
            [GANHelper analyzeEvent:@"accept_policy" category:self.analyticsCategory];
        } else {
            [GANHelper analyzeEvent:@"decline_policy" category:self.analyticsCategory];
        }
        
        [self reload:YES];
    } forControlEvents:UIControlEventValueChanged];
}

- (void)reload:(BOOL)animated{
    [super reload:animated];
    
    BOOL ndaSigned = [[NSUserDefaults standardUserDefaults] boolForKey:kDBDefaultsNDASigned];
    
    self.ndaAcceptSwitch.on = ndaSigned;
    if(ndaSigned){
        self.labelNda.textColor = [UIColor blackColor];
    } else {
        self.labelNda.textColor = [UIColor db_errorColor];
    }
}

- (CGSize)moduleViewContentSize {
    
}

- (void)touchAtLocation:(CGPoint)location {
    if (!CGRectContainsPoint(self.ndaAcceptSwitch.frame, location)) {
        DBHTMLViewController *ndaVC = [DBHTMLViewController new];
        ndaVC.title = NSLocalizedString(@"Правила оплаты", nil);
        ndaVC.url = [DBCompanyInfo db_paymentRulesUrl];
        ndaVC.screen = PAYMENT_RULES_SCREEN;
        
        [GANHelper analyzeEvent:@"confidence_show" category:self.analyticsCategory];
        
        ndaVC.hidesBottomBarWhenPushed = YES;
        [self.ownerViewController.navigationController pushViewController:ndaVC animated:YES];
    }
}

@end
