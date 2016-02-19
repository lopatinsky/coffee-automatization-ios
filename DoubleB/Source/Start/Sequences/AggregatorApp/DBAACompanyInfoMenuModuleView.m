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
    
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = self.topBarView.bounds;
        _gradientLayer.colors = @[(id)[UIColor blackColor].CGColor, (id)[UIColor clearColor].CGColor];
        _gradientLayer.startPoint = CGPointMake(0.5, 0.0);
        _gradientLayer.endPoint = CGPointMake(0.5, 1.0);
        [self.topBarView.layer insertSublayer:_gradientLayer atIndex:0];
    }
    
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
    
    _companyTitle.text = [DBCompaniesManager selectedCompany].companyName;
}


@end
