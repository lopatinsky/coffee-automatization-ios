//
//  DBAACompanyInfoMenuModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 16/02/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBAACompanyInfoMenuModuleView.h"
#import "DBCompanyInfo.h"

#import "DBCompanyInfoViewController.h"
#import "DBPromosListViewController.h"
#import "DBCompaniesManager.h"

#import "UIView+Gradient.h"
#import "UIImageView+WebCache.h"
#import "UIGestureRecognizer+BlocksKit.h"

@interface DBAACompanyInfoMenuModuleView ()
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIView *topBarView;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UIImageView *infoImageView;

@property (weak, nonatomic) IBOutlet UIView *promosView;
@property (weak, nonatomic) IBOutlet UIImageView *promosImageView;

@property (weak, nonatomic) IBOutlet UIImageView *companyImageView;
@property (weak, nonatomic) IBOutlet UILabel *companyTitle;

@end

@implementation DBAACompanyInfoMenuModuleView{
    CAGradientLayer *_gradientLayer;
}

+ (NSString *)xibName {
    return @"DBAACompanyInfoMenuModuleView";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [_promosImageView templateImageWithName:@"promos_icon" tintColor:[UIColor whiteColor]];
    _promosView.userInteractionEnabled = YES;
    [_promosView addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        DBPromosListViewController *promosVC = [DBPromosListViewController new];
        [self.ownerViewController.navigationController pushViewController:promosVC animated:YES];
    }]];
    
    [_infoImageView templateImageWithName:@"info_icon" tintColor:[UIColor whiteColor]];
    _infoView.userInteractionEnabled = YES;
    [_infoView addGestureRecognizer:[UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        DBCompanyInfoViewController *infoVC = [DBCompanyInfoViewController new];
        [self.ownerViewController.navigationController pushViewController:infoVC animated:YES];
    }]];
    [_bgImageView sd_setImageWithURL:[NSURL URLWithString:[DBCompaniesManager selectedCompany].companyImageUrl]];
    // TODO: decide about company logo
    [_companyImageView sd_setImageWithURL:[NSURL URLWithString:@"yandex.ru"] placeholderImage:[UIImage imageNamed:@"coffee_logo_placeholder"]];
    _companyImageView.layer.cornerRadius = 5.f;
    _companyTitle.text = [[DBCompanyInfo sharedInstance] applicationName];
    
    [self.topBarView addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"bounds"]) {
        [self.topBarView setGradientWithColors:[NSArray arrayWithObjects:(id)[[UIColor grayColor] colorWithAlphaComponent:0.4].CGColor, (id)[UIColor clearColor].CGColor, nil]];
    }
}

@end
